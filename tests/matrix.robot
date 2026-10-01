*** Settings ***
Library    SSHLibrary
Library    Collections
Resource    api.resource

*** Variables ***
${ADMIN_USER}    admin
${ADMIN_PASSWORD}    Nethesis,1234
${SCENARIO}    install
${user_domain}    ldap.dom.test
${user_password}    Nethesis,1234
${synapse_host}    matrix.dom.test
${synapse_api}    https://127.0.0.1/_matrix/client/v3
${message}    message kept across the update

*** Keywords ***
Login to cluster-admin
    New Page    https://${NODE_ADDR}/cluster-admin/
    Fill Text    text="Username"    ${ADMIN_USER}
    Click    button >> text="Continue"
    Fill Text    text="Password"    ${ADMIN_PASSWORD}
    Click    button >> text="Log in"
    Wait For Elements State    css=#main-content    visible    timeout=10s

Add module
    [Arguments]    ${image}
    ${output}  ${rc} =    Execute Command    add-module ${image} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    RETURN    ${output}

Retry test
    [Arguments]    ${keyword}
    Wait Until Keyword Succeeds    60 seconds    1 second    ${keyword}

Backend URL is reachable
    ${rc} =    Execute Command    curl -f ${backend_url}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Synapse
    [Arguments]    ${method}    ${path}    ${body}=${EMPTY}    ${token}=${EMPTY}
    ${auth} =    Set Variable If    '${token}' != ''    -H "Authorization: Bearer ${token}"    ${EMPTY}
    ${data} =    Set Variable If    '''${body}''' != ''    -d '${body}'    ${EMPTY}
    ${out} =    Execute Command    curl -sk -X ${method} -H "Host: ${synapse_host}" -H "Content-Type: application/json" ${auth} ${data} "${synapse_api}${path}"
    ${response} =    Evaluate    json.loads($out)    modules=json
    RETURN    ${response}

Log in
    [Arguments]    ${user}    ${password}=${user_password}
    ${response} =    Synapse    POST    /login    {"type":"m.login.password","identifier":{"type":"m.id.user","user":"${user}"},"password":"${password}"}
    RETURN    ${response}

Get a token for
    [Arguments]    ${user}
    ${response} =    Log in    ${user}
    Dictionary Should Contain Key    ${response}    access_token    ${user} cannot log in with its LDAP password: ${response}
    RETURN    ${response['access_token']}

Service is active
    [Arguments]    ${service}
    ${output} =    Execute Command    runagent -m ${module_id} systemctl --user show --property=ActiveState ${service}
    Should Be Equal As Strings    ${output}    ActiveState=active

Synapse answers
    ${rc} =    Execute Command    curl -skf -o /dev/null -H "Host: ${synapse_host}" https://127.0.0.1/_matrix/client/versions
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

user2 reads the message of user1
    ${response} =    Synapse    GET    /rooms/${room_id}/messages?dir=b&limit=20    token=${token2}
    ${bodies} =    Evaluate    [e['content'].get('body') for e in $response['chunk'] if e['type'] == 'm.room.message']
    Should Contain    ${bodies}    ${message}

*** Test Cases ***
Configure the LDAP user domain
    ${response} =    Run task    cluster/add-internal-provider    {"image":"openldap","node":1}
    Set Suite Variable    ${mid_ldap}    ${response['module_id']}
    Run task    module/${mid_ldap}/configure-module    {"domain":"${user_domain}","admuser":"admin","admpass":"${user_password}","provision":"new-domain"}
    Run task    module/${mid_ldap}/add-user    {"user":"user1","display_name":"User One","password":"${user_password}"}
    Run task    module/${mid_ldap}/add-user    {"user":"user2","display_name":"User Two","password":"${user_password}"}

Check if matrix is installed correctly
    # The update scenario starts from the NS8 stable release, then upgrades it below.
    # matrix is published in NethForge, which a new node has disabled.
    IF    '${SCENARIO}' == 'update'
        Run task    cluster/alter-repository    {"name":"nethforge","status":true}
        ${output} =    Wait Until Keyword Succeeds    5 times    10 seconds    Add module    matrix
    ELSE
        ${output} =    Add module    ${IMAGE_URL}
    END
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${module_id}    ${output.module_id}

Take screenshots
    [Tags]    ui
    Import Library    Browser
    New Browser    chromium    headless=True
    New Context    ignoreHTTPSErrors=True
    Login to cluster-admin
    Go To    https://${NODE_ADDR}/cluster-admin/#/apps/${module_id}
    Wait For Elements State    iframe >>> h2 >> text="Status"    visible    timeout=10s
    Sleep    5s
    Take Screenshot    filename=${OUTPUT DIR}/browser/screenshot/1._Status.png
    Go To    https://${NODE_ADDR}/cluster-admin/#/apps/${module_id}?page=settings
    Wait For Elements State    iframe >>> h2 >> text="Settings"    visible    timeout=10s
    Sleep    5s
    Take Screenshot    filename=${OUTPUT DIR}/browser/screenshot/2._Settings.png
    Close Browser

Check if matrix can be configured
    ${rc} =    Execute Command    api-cli run module/${module_id}/configure-module --data '{"synapse_domain_name": "${synapse_host}", "element_domain_name": "chat.dom.test", "cinny_domain_name": "cinny.dom.test", "lets_encrypt": false, "ldap_domain": "${user_domain}", "mail_from": "noreply@example.com", "nethvoice_auth_url": "https://nethvoice.nethserver.org/freepbx/rest/testextauth"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

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
    FOR    ${service}    IN    postgresql    synapse    element-web    cinny
        Wait Until Keyword Succeeds    30 times    5 seconds    Service is active    ${service}
    END
    Wait Until Keyword Succeeds    30 times    5 seconds    Synapse answers

Check LDAP users can log in
    # Synapse limits logins per account, so each user logs in once and keeps its token
    ${token} =    Get a token for    user1
    Set Suite Variable    ${token1}    ${token}
    ${token} =    Get a token for    user2
    Set Suite Variable    ${token2}    ${token}
    ${response} =    Log in    user1    wrong-password
    Should Be Equal    ${response['errcode']}    M_FORBIDDEN

Send a message in a room
    ${room} =    Synapse    POST    /createRoom    {"name":"upgrade","invite":["@user2:${synapse_host}"]}    token=${token1}
    Set Suite Variable    ${room_id}    ${room['room_id']}
    Synapse    POST    /rooms/${room_id}/join    {}    token=${token2}
    ${sent} =    Synapse    PUT    /rooms/${room_id}/send/m.room.message/upgrade-test    {"msgtype":"m.text","body":"${message}"}    token=${token1}
    Dictionary Should Contain Key    ${sent}    event_id
    user2 reads the message of user1

Update matrix to the image under test
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}, nothing to update
    ${rc} =    Execute Command
    ...    api-cli run update-module --data '{"force":true,"module_url":"${IMAGE_URL}","instances":["${module_id}"]}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Check matrix works after the update
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}, nothing to update
    FOR    ${service}    IN    postgresql    synapse    element-web    cinny
        Wait Until Keyword Succeeds    30 times    5 seconds    Service is active    ${service}
    END
    Wait Until Keyword Succeeds    30 times    5 seconds    Synapse answers
    Get a token for    user1

Check the configuration survives the update
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}, nothing to update
    ${config} =    Run task    module/${module_id}/get-configuration    {}
    Should Be Equal    ${config['synapse_domain_name']}    ${synapse_host}
    Should Be Equal    ${config['ldap_domain']}    ${user_domain}

Check the message and the session survive the update
    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}, nothing to update
    # The token of user2 was issued before the update
    user2 reads the message of user1

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

Remove the LDAP user domain
    Run task    cluster/remove-internal-domain    {"domain":"${user_domain}"}
