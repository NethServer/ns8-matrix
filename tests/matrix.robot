*** Settings ***
Library    SSHLibrary
Resource    api.resource

*** Variables ***
${MID}            matrix1

*** Keywords ***
Retry test
    [Arguments]    ${keyword}
    Wait Until Keyword Succeeds    60 seconds    1 second    ${keyword}

Backend URL is reachable
    ${rc} =    Execute Command    curl -f ${backend_url}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

*** Test Cases ***
Check if matrix is installed correctly
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${module_id}    ${output.module_id}

Check if matrix can be configured
    ${rc} =    Execute Command    api-cli run module/${module_id}/configure-module --data '{"synapse_domain_name": "matrix.example.com", "element_domain_name": "chat.example.com", "cinny_domain_name": "cinny.example.com", "lets_encrypt": true, "ldap_domain": "users.example.com", "mail_from": "noreply@example.com", "nethvoice_auth_url": "https://nethvoice.nethserver.org/freepbx/rest/testextauth"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check if postgresql service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${MID} systemctl --user show --property=LoadState postgresql
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Check if synapse service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${MID} systemctl --user show --property=LoadState synapse
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Check if element service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${MID} systemctl --user show --property=LoadState element-web
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Check if cinny service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${MID} systemctl --user show --property=LoadState cinny
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Check if matrix2acrobits service is loaded correctly
    ${output}  ${rc} =    Execute Command    runagent -m ${MID} systemctl --user show --property=LoadState matrix2acrobits
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    Should Be Equal As Strings    ${output}    LoadState=loaded

Retrieve element backend URL
    # Assuming the test is running on a single node cluster
    ${response} =    Run task     module/traefik1/get-route    {"instance":"${module_id}-element"}
    Set Suite Variable    ${backend_url}    ${response['url']}

Check if element works as expected
    Retry test    Backend URL is reachable

Verify element frontend title
    ${output} =    Execute Command    curl -s ${backend_url}
    Should Contain    ${output}    <title>Element</title>

Retrieve cinny backend URL
    # Assuming the test is running on a single node cluster
    ${response} =    Run task     module/traefik1/get-route    {"instance":"${module_id}-cinny"}
    Set Suite Variable    ${backend_url}    ${response['url']}

Check if cinny works as expected
    Retry test    Backend URL is reachable

Verify cinny frontend title
    ${output} =    Execute Command    curl -s ${backend_url}
    Should Contain    ${output}    <title>Cinny</title>

Check if matrix is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
