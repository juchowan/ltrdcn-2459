*** Settings ***
Documentation   Verify Tenant Health
Suite Setup     Login APIC
Default Tags    apic   day2   health   tenants
Resource        ./apic_common.resource

*** Test Cases ***
{% for tenant in apic.tenants | default([]) %}

Verify Tenant {{ tenant.name }} Faults
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/fltCnts.json
    ${minor}=   Get Value From Json   ${r.json()}   $..faultCountsWithDetails.attributes.minor
    Run Keyword If   ${minor}[0] > 0   Run Keyword And Continue On Failure
    ...   Fail  "{{ tenant.name }} has ${minor}[0] minor faults"

Verify Tenant {{ tenant.name }} Health
    ${r}=   GET On Session   apic   /api/mo/uni/tn-{{ tenant.name }}/health.json
    ${health}=   Get Value From Json   ${r.json()}   $..healthInst.attributes.cur
    Run Keyword If   ${health}[0] < 100   Run Keyword And Continue On Failure
    ...   Fail  "{{ tenant.name }} health score: ${health}[0]"

{% endfor %}