*** Settings ***
Library    pabot.PabotLib
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Library    String
Library    Process

*** Keywords ***
Get FMC Token
    ${auth}=    Create List    %{FMC_USERNAME}    %{FMC_PASSWORD}
    ${verify}=    Set Variable If    "%{FMC_INSECURE_SKIP_VERIFY}" == "False"    True    False
    ${log_level}=   Set Log Level   NONE
    Create Session    fmc_login    %{FMC_URL}   auth=${auth}  verify=${verify}    disable_warnings=1
    Set Log Level   ${log_level}
    ${response}=    Wait Until Keyword Succeeds    1x    10s    POST On Session    fmc_login    /api/fmc_platform/v1/auth/generatetoken
    
    ${fmc_domain_map}=    Create Dictionary
    ${domain_list}    Evaluate    json.loads('''${response.headers['DOMAINS']}''')
    FOR    ${element}    IN    @{domain_list}
        Set To Dictionary    ${fmc_domain_map}    ${element['name']}    ${element['uuid']}
    END

    Set Parallel Value For Key    fmc_token    ${response.headers['X-auth-access-token']}
    Set Parallel Value For Key    fmc_domain_map    ${fmc_domain_map}

Login FMC
    Run Only Once    Get FMC Token
    ${fmc_token}=    Get Parallel Value For Key    fmc_token
    ${fmc_domain_map}=    Get Parallel Value For Key    fmc_domain_map 
    Create Session    fmc    %{FMC_URL}    headers={"content-type": "application/json", "X-auth-access-token":"${fmc_token}"}    disable_warnings=1
    Set Global Variable    ${FMC_DOMAIN_MAP}    ${fmc_domain_map}

Should Be Equal Value Json String
    [Arguments]    ${json}    ${json_path}   ${value}=${EMPTY}
    ${r_value}=   Get Value From Json   ${json}   ${json_path}
    Run Keyword If   "${value}" != "${EMPTY}"   Should Be Equal As Strings   ${r_value}[0]   ${value}

Get All Objects By Name
    [Arguments]    ${url}     ${key}=${None}
    ${r}=    GET On Session    fmc    url=${url}expanded=true&limit=10000
    IF     'items' not in @{r.json()}
        @{objects}      Create List
    ELSE
        @{objects}      Create List    @{r.json()['items']}
    END

    WHILE    'next' in @{r.json()['paging']}
        ${r}=       GET On Session    fmc    url=${r.json()['paging']['next'][0]}
        Append To List    ${objects}       @{r.json()['items']}
    END



    ${objects_by_name}=    Create Dictionary
    FOR    ${element}    IN    @{objects}
        IF    "${key}" == "${None}"    
            Set To Dictionary    ${objects_by_name}    ${element['name']}    ${element}
        ELSE
            Set To Dictionary    ${objects_by_name}    ${element['${key}']}     ${element}
        END
    END

    [Return]    ${objects_by_name}
