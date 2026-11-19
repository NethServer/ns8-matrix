*** Settings ***
Library    SSHLibrary
Resource    api.resource
Resource    matrix.resource

*** Test Cases ***
Check if matrix is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Remove the LDAP user domain
    Run task    cluster/remove-internal-domain    {"domain":"${user_domain}"}
