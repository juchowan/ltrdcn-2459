*** Settings ***
Documentation    Verify Hosts
Suite Setup      Run Keywords    Login FMC    AND    Get All Hosts
Default Tags     fmc    day1    config    hosts
Resource    ./fmc_common.resource
Library    String

*** Keywords ***
Get All Hosts
{% for domain in fmc.domains | default([]) %}
{% if domain.objects.hosts is defined %}
    ${HOSTS_{{ domain.name }}}=    Get All Objects By Name    /api/fmc_config/v1/domain/${FMC_DOMAIN_MAP['{{ domain.name }}']}/object/hosts?
    Set Global Variable    ${HOSTS_{{ domain.name }}}
{% endif %}
{% endfor %}

*** Test Cases ***
{% for domain in fmc.domains | default([]) %}
{% for host in domain.objects.hosts | default([]) %}

Verify Host - {{ host.name }}
    Run Keyword If    '{{ host.name }}' not in @{HOSTS_{{ domain.name }}}    Fail    Item not found on FMC
    ${HOST}=    Set Variable    ${HOSTS_{{ domain.name }}['{{ host.name }}']}

    Should Be Equal Value Json String    ${HOST}   $.name           {{ host.name }}
    Should Be Equal    ${HOST['value'].lower()}    {{ host.ip | lower }}
    
    {% if host.description is defined or defaults.fmc.domains.objects.hosts.description is defined %}
    Should Be Equal Value Json String    ${HOST}   $.description    {{ host.description | default(defaults.fmc.domains.objects.hosts.description) }}
    {% endif %}

    {% if host.overridable is defined or defaults.fmc.domains.objects.hosts.overridable is defined %}
    Should Be Equal Value Json String    ${HOST}   $.overridable    {{ host.overridable | default(defaults.fmc.domains.objects.hosts.overridable) }}
    {% endif %}

{% endfor %}
{% endfor %}