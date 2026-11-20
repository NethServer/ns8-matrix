*** Settings ***
Library    SSHLibrary
Library    Collections
Resource    api.resource

*** Variables ***
${SCENARIO}    install
${user_domain}    ldap.dom.test
${user_password}    Nethesis,1234
${synapse_host}    matrix.dom.test
${synapse_api}    https://127.0.0.1/_matrix/client/v3
${message}    message kept across the update
${element_host}    chat.dom.test
${cinny_host}    cinny.dom.test
${resolve_test_hosts}    --resolve ${synapse_host}:443:127.0.0.1 --resolve ${element_host}:443:127.0.0.1 --resolve ${cinny_host}:443:127.0.0.1
${base_config}    "synapse_domain_name": "${synapse_host}", "element_domain_name": "${element_host}", "cinny_domain_name": "${cinny_host}", "lets_encrypt": false, "ldap_domain": "${user_domain}", "mail_from": "noreply@example.com", "nethvoice_auth_url": ""

*** Keywords ***
Add module
    [Arguments]    ${image}
    ${output}  ${rc} =    Execute Command    add-module ${image} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    RETURN    ${output}

Synapse
    [Arguments]    ${method}    ${path}    ${body}=${EMPTY}    ${token}=${EMPTY}
    ${auth} =    Set Variable If    '${token}' != ''    -H "Authorization: Bearer ${token}"    ${EMPTY}
    ${data} =    Set Variable If    '''${body}''' != ''    -d '${body}'    ${EMPTY}
    ${out} =    Execute Command    curl -sk -X ${method} -H "Host: ${synapse_host}" -H "Content-Type: application/json" ${auth} ${data} "${synapse_api}${path}"
    ${response} =    Evaluate    json.loads($out)    modules=json
    RETURN    ${response}

Log in
    [Arguments]    ${user}    ${password}=${user_password}
    # Synapse allows a few logins per client address, and through Traefik every
    # test call comes from 127.0.0.1. Log in on the Synapse port instead, with
    # its own forwarded address, so the suites do not hit that limit.
    ${address} =    Evaluate    f"10.99.{random.randint(0, 255)}.{random.randint(1, 254)}"    modules=random
    ${out} =    Execute Command    curl -s -X POST -H "X-Forwarded-For: ${address}" -H "Content-Type: application/json" -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"${user}"},"password":"${password}"}' "http://127.0.0.1:${synapse_port}/_matrix/client/v3/login"
    ${response} =    Evaluate    json.loads($out)    modules=json
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

Read the Synapse port
    [Documentation]    Call it whenever ${module_id} changes
    ${port} =    Execute Command    runagent -m ${module_id} sh -c 'grep ^SYNAPSE_PORT= config.env | cut -d= -f2'
    Should Not Be Empty    ${port}
    Set Global Variable    ${synapse_port}    ${port.strip()}

Matrix is running
    FOR    ${service}    IN    postgresql    synapse    element-web    cinny
        Wait Until Keyword Succeeds    30 times    5 seconds    Service is active    ${service}
    END
    Wait Until Keyword Succeeds    30 times    5 seconds    Synapse answers

Synapse answers
    ${rc} =    Execute Command    curl -skf -o /dev/null -H "Host: ${synapse_host}" https://127.0.0.1/_matrix/client/versions
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

user2 reads the message of user1
    ${response} =    Synapse    GET    /rooms/${room_id}/messages?dir=b&limit=20    token=${token2}
    ${bodies} =    Evaluate    [e['content'].get('body') for e in $response['chunk'] if e['type'] == 'm.room.message']
    Should Contain    ${bodies}    ${message}

HTTP status of
    [Arguments]    ${path}    ${token}=${EMPTY}
    ${auth} =    Set Variable If    '${token}' != ''    -H "Authorization: Bearer ${token}"    ${EMPTY}
    ${code} =    Execute Command    curl -sk -o /dev/null -w "\%{http_code}" -H "Host: ${synapse_host}" ${auth} "https://127.0.0.1${path}"
    RETURN    ${code}

Curl client
    [Documentation]    Call a public URL as a browser on ${origin} would, resolving every test host to this node
    [Arguments]    ${url}    ${origin}=${EMPTY}    ${options}=${EMPTY}
    ${hdr} =    Set Variable If    '${origin}' != ''    -H "Origin: ${origin}"    ${EMPTY}
    ${out} =    Execute Command    curl -sk ${resolve_test_hosts} ${hdr} ${options} "${url}"
    RETURN    ${out}

Matrix fingerprint
    [Documentation]    Row counts and a hash of every message, to compare the database before and after an operation
    ${out}    ${rc} =    Execute Command
    ...    runagent -m ${module_id} podman exec -i postgresql psql -U postgres -At synapse -c "select (select count(*) from users), (select count(*) from events), (select count(*) from rooms), (select count(*) from local_media_repository), (select md5(string_agg(e.event_id || ej.json, '' order by e.stream_ordering)) from events e join event_json ej using (event_id) where e.type = 'm.room.message')"
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}    0
    RETURN    ${out.strip()}

Configure matrix with
    [Documentation]    Configure the module with the base settings, overridden by ${extra}
    [Arguments]    ${extra}
    ${payload} =    Evaluate    json.dumps({**json.loads('{' + $base_config + '}'), **json.loads('{' + $extra + '}')})    modules=json
    Run task    module/${module_id}/configure-module    ${payload}    decode_json=${FALSE}
    Wait Until Keyword Succeeds    30 times    5 seconds    Synapse answers

user1 finds user2 in the directory
    ${response} =    Synapse    POST    /user_directory/search    {"search_term":"user2"}    token=${token1}
    ${ids} =    Evaluate    [r['user_id'] for r in $response['results']]
    Should Contain    ${ids}    @user2:${synapse_host}

Matrix pod is running
    ${rc} =    Execute Command    runagent -m ${module_id} podman pod exists matrix
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Services listen on localhost only
    # Traefik reaches every service on 127.0.0.1, any wider bind exposes it to the network
    FOR    ${var}    IN    SYNAPSE_PORT    ELEMENT_WEB_PORT    CINNY_PORT    M2A_PROXY_PORT
        ${port} =    Execute Command    runagent -m ${module_id} sh -c 'grep ^${var}= config.env | cut -d= -f2'
        Should Not Be Empty    ${port}
        ${addresses} =    Execute Command    ss -ltnH 'sport = :${port.strip()}' | awk '{print $4}'
        Should Not Be Empty    ${addresses}    nothing listens on ${var} ${port}
        FOR    ${address}    IN    @{addresses.splitlines()}
            Should Be Equal    ${address}    127.0.0.1:${port.strip()}    ${var} listens on ${address}
        END
    END
    # PostgreSQL is reachable only inside the pod
    ${port} =    Execute Command    runagent -m ${module_id} sh -c 'grep ^POSTGRES_PORT= config.env | cut -d= -f2'
    ${addresses} =    Execute Command    ss -ltnH 'sport = :${port.strip()}'
    Should Be Empty    ${addresses}    PostgreSQL is published on the node
