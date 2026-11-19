*** Settings ***
Library    SSHLibrary
Resource    api.resource
Resource    matrix.resource
# Element and Cinny are static JavaScript apps: these tests replay the
# requests the apps send to log in, without running a browser.
Test Template    Web client can log in

*** Keywords ***
Web client can log in
    [Arguments]    ${client}    ${host}    ${title}    ${user}
    ${origin} =    Set Variable    https://${host}

    ${page} =    Curl client    ${origin}/
    Should Contain    ${page}    <title>${title}</title>

    ${out} =    Curl client    ${origin}/config.json
    ${config} =    Evaluate    json.loads($out)    modules=json
    IF    '${client}' == 'element'
        Should Be Equal    ${config['default_server_config']['m.homeserver']['base_url']}    https://${synapse_host}
    ELSE
        Should Contain    ${config['homeserverList']}    ${synapse_host}
    END

    ${out} =    Curl client    https://${synapse_host}/.well-known/matrix/client    ${origin}
    ${wellknown} =    Evaluate    json.loads($out)    modules=json
    Should Start With    ${wellknown['m.homeserver']['base_url']}    https://${synapse_host}

    # The browser checks CORS before posting the login from another domain
    ${headers} =    Curl client    https://${synapse_host}/_matrix/client/v3/login    ${origin}
    ...    -X OPTIONS -D - -o /dev/null -H "Access-Control-Request-Method: POST" -H "Access-Control-Request-Headers: content-type,authorization"
    Should Match Regexp    ${headers}    (?i)access-control-allow-origin: (\\*|${origin})
    Should Match Regexp    ${headers}    (?i)access-control-allow-headers:.*authorization

    ${out} =    Curl client    https://${synapse_host}/_matrix/client/v3/login    ${origin}
    ${flows} =    Evaluate    [f['type'] for f in json.loads($out)['flows']]    modules=json
    Should Contain    ${flows}    m.login.password

    ${out} =    Curl client    https://${synapse_host}/_matrix/client/v3/login    ${origin}
    ...    -X POST -H "Content-Type: application/json" -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"${user}"},"password":"${user_password}","initial_device_display_name":"${title} test"}'
    ${login} =    Evaluate    json.loads($out)    modules=json
    Dictionary Should Contain Key    ${login}    access_token    ${user} cannot log in from ${title}: ${login}
    ${auth} =    Set Variable    -H "Authorization: Bearer ${login['access_token']}"

    ${out} =    Curl client    https://${synapse_host}/_matrix/client/v3/createRoom    ${origin}
    ...    -X POST ${auth} -H "Content-Type: application/json" -d '{"name":"${title} room"}'
    ${room} =    Evaluate    json.loads($out)['room_id']    modules=json

    ${out} =    Curl client    https://${synapse_host}/_matrix/client/v3/sync?timeout=0    ${origin}    ${auth}
    ${sync} =    Evaluate    json.loads($out)    modules=json
    Dictionary Should Contain Key    ${sync['rooms']['join']}    ${room}

    ${out} =    Curl client    https://${synapse_host}/_matrix/client/v3/rooms/${room}/send/m.room.message/${client}-web-test    ${origin}
    ...    -X PUT ${auth} -H "Content-Type: application/json" -d '{"msgtype":"m.text","body":"sent from ${title}"}'
    ${sent} =    Evaluate    json.loads($out)    modules=json
    Dictionary Should Contain Key    ${sent}    event_id

    Curl client    https://${synapse_host}/_matrix/client/v3/logout    ${origin}    -X POST ${auth} -d '{}'

*** Test Cases ***    CLIENT     HOST               TITLE      USER
Element login         element    ${element_host}    Element    web1
Cinny login           cinny      ${cinny_host}      Cinny      web2
