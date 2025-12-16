*** Settings ***
Library    SSHLibrary
Resource    api.resource

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

Check if matrix services are running
    Sleep    30s    # Wait for services to start
    ${rc} =    Execute Command    systemctl --user is-active postgresql
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
    ${rc} =    Execute Command    systemctl --user is-active synapse
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
    ${rc} =    Execute Command    systemctl --user is-active element-web
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
    ${rc} =    Execute Command    systemctl --user is-active cinny
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
    ${rc} =    Execute Command    systemctl --user is-active matrix2acrobits
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

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
