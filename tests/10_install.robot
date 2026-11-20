*** Settings ***
Library    SSHLibrary
Resource    api.resource
Resource    matrix.resource

*** Test Cases ***
Configure the LDAP user domain
    ${response} =    Run task    cluster/add-internal-provider    {"image":"openldap","node":1}
    Set Global Variable    ${mid_ldap}    ${response['module_id']}
    Run task    module/${mid_ldap}/configure-module    {"domain":"${user_domain}","admuser":"admin","admpass":"${user_password}","provision":"new-domain"}
    Run task    module/${mid_ldap}/add-user    {"user":"user1","display_name":"User One","password":"${user_password}"}
    Run task    module/${mid_ldap}/add-user    {"user":"user2","display_name":"User Two","password":"${user_password}"}
    # One account per web client test: Synapse rate-limits logins per account
    Run task    module/${mid_ldap}/add-user    {"user":"web1","display_name":"Element Tester","password":"${user_password}"}
    Run task    module/${mid_ldap}/add-user    {"user":"web2","display_name":"Cinny Tester","password":"${user_password}"}

Check if matrix is installed correctly
    # The update scenario starts from the NS8 stable release, then upgrades it in 22_update.
    # matrix is published in NethForge, which a new node has disabled.
    IF    '${SCENARIO}' == 'update'
        Run task    cluster/alter-repository    {"name":"nethforge","status":true}
        ${output} =    Wait Until Keyword Succeeds    5 times    10 seconds    Add module    matrix
    ELSE
        ${output} =    Add module    ${IMAGE_URL}
    END
    &{output} =    Evaluate    ${output}
    Set Global Variable    ${module_id}    ${output.module_id}

Check if matrix can be configured
    Configure matrix with    "nethvoice_auth_url": "https://nethvoice.nethserver.org/freepbx/rest/testextauth"
    Read the Synapse port

Check if the matrix pod is running
    Skip If    '${SCENARIO}' == 'update'    checked after the update
    Matrix pod is running

Check if postgresql service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${module_id} systemctl --user show --property=LoadState postgresql
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Check if synapse service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${module_id} systemctl --user show --property=LoadState synapse
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Check if element service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${module_id} systemctl --user show --property=LoadState element-web
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Check if cinny service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${module_id} systemctl --user show --property=LoadState cinny
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Check if matrix2acrobits service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${module_id} systemctl --user show --property=LoadState matrix2acrobits
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Check the services are running
    Matrix is running

Check the services listen on localhost only
    # The update scenario installed the stable release, 22_update checks the image under test
    Skip If    '${SCENARIO}' == 'update'    checked after the update
    Services listen on localhost only
