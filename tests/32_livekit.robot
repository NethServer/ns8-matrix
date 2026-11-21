*** Settings ***
Library    SSHLibrary
Resource    api.resource
Resource    matrix.resource
Suite Teardown    Turn LiveKit off and forget the test host

*** Variables ***
${hosts_marker}    # matrix-livekit-test

*** Keywords ***
Resolve the Synapse domain on the node
    # lk-jwt-service calls https://${synapse_host} to check users, and the CI has no DNS for it.
    # Podman copies the node /etc/hosts into the containers it creates afterwards.
    ${address} =    Execute Command    ip -4 route get 1.1.1.1 | grep -oP 'src \\K\\S+'
    Should Not Be Empty    ${address}
    Execute Command    echo '${address.strip()} ${synapse_host} ${hosts_marker}' >> /etc/hosts

Turn LiveKit off and forget the test host
    Configure matrix with    "livekit_enabled": false
    Execute Command    sed -i '/${hosts_marker}/d' /etc/hosts

Route of
    [Arguments]    ${suffix}
    ${route} =    Run task    module/traefik1/get-route    {"instance":"${module_id}${suffix}"}
    RETURN    ${route}

Public ports of the module
    ${out} =    Execute Command    firewall-cmd --info-service=${module_id} 2>/dev/null | grep -E '^ +ports:'
    RETURN    ${out}

Module environment
    [Arguments]    ${name}
    ${out} =    Execute Command    runagent -m ${module_id} printenv ${name}
    RETURN    ${out.strip()}

LiveKit token for user1
    ${openid} =    Synapse    POST    /user/@user1:${synapse_host}/openid/request_token    {}    token=${token1}
    ${body} =    Evaluate    json.dumps({"room_id": "!livekit-test:${synapse_host}", "slot_id": "m.call#ROOM", "openid_token": $openid, "member": {"id": "user1_ROBOT", "claimed_user_id": "@user1:${synapse_host}", "claimed_device_id": "ROBOT"}})    modules=json
    ${out} =    Execute Command    curl -sk -X POST -H "Host: ${synapse_host}" -H "Content-Type: application/json" -d '${body}' https://127.0.0.1/livekit/jwt/get_token
    ${response} =    Evaluate    json.loads($out)    modules=json
    RETURN    ${response}

*** Test Cases ***
Check LiveKit is off by default
    ${route} =    Route of    -livekit-sfu
    Should Be Empty    ${route}
    ${ports} =    Public ports of the module
    Should Not Contain    ${ports}    7882

Check the TURN relay range comes from the NS8 allocator
    ${range} =    Module environment    UDP_PORTS_RANGE
    Should Match Regexp    ${range}    ^\\d+-\\d+$
    ${size} =    Evaluate    int($range.split('-')[1]) - int($range.split('-')[0]) + 1
    Should Be Equal As Integers    ${size}    1024

Check LiveKit can be enabled
    Resolve the Synapse domain on the node
    # The CI certificate is self signed, lk-jwt-service would refuse it
    Configure matrix with    "livekit_enabled": true, "livekit_turn_enabled": true, "livekit_tls_skip_verify": true
    Wait Until Keyword Succeeds    30 times    5 seconds    Service is active    livekit
    Wait Until Keyword Succeeds    30 times    5 seconds    Service is active    lk-jwt
    FOR    ${suffix}    ${path}    IN    -livekit-sfu    /livekit/sfu    -livekit-jwt    /livekit/jwt
        ${route} =    Route of    ${suffix}
        Should Be Equal    ${route['host']}    ${synapse_host}
        Should Be Equal    ${route['path']}    ${path}
        Should Be True    ${route['strip_prefix']}
    END
    ${ports} =    Public ports of the module
    Should Contain    ${ports}    7881/tcp
    Should Contain    ${ports}    7882/udp
    Should Contain    ${ports}    3478/udp

Check LiveKit uses the allocated relay range
    ${range} =    Module environment    UDP_PORTS_RANGE
    ${first}    ${last} =    Evaluate    $range.split('-')
    ${config} =    Execute Command    runagent -m ${module_id} cat livekit-config/livekit.yaml
    Should Contain    ${config}    relay_range_start: ${first}
    Should Contain    ${config}    relay_range_end: ${last}
    Should Contain    ${config}    udp_port: 7882

Check Synapse advertises LiveKit
    ${out} =    Execute Command    curl -sk -H "Host: ${synapse_host}" -H "Authorization: Bearer ${token1}" https://127.0.0.1/_matrix/client/v1/rtc/transports
    ${response} =    Evaluate    json.loads($out)    modules=json
    ${types} =    Evaluate    [t['type'] for t in $response['transports']]
    Should Contain    ${types}    m.livekit
    Should Contain    ${types}    livekit
    ${out} =    Execute Command    curl -sk -H "Host: ${synapse_host}" https://127.0.0.1/.well-known/matrix/client
    ${wellknown} =    Evaluate    json.loads($out)    modules=json
    Should Be Equal    ${wellknown['org.matrix.msc4143.rtc_foci'][0]['livekit_service_url']}    https://${synapse_host}/livekit/jwt

Check a Matrix user gets a LiveKit token
    # The whole chain: OpenID token from Synapse, lk-jwt-service checks it back through Traefik
    ${response} =    Wait Until Keyword Succeeds    12 times    5 seconds    LiveKit token for user1
    Dictionary Should Contain Key    ${response}    jwt    lk-jwt-service refused the token: ${response}
    Should Be Equal    ${response['url']}    wss://${synapse_host}/livekit/sfu
    ${code} =    HTTP status of    /livekit/sfu/
    Should Be Equal    ${code}    200

Check LiveKit can be disabled
    Configure matrix with    "livekit_enabled": false
    FOR    ${suffix}    IN    -livekit-sfu    -livekit-jwt
        ${route} =    Route of    ${suffix}
        Should Be Empty    ${route}
    END
    ${ports} =    Public ports of the module
    Should Not Contain    ${ports}    7882
    FOR    ${service}    IN    livekit    lk-jwt
        ${output} =    Execute Command    runagent -m ${module_id} systemctl --user is-active ${service}
        Should Not Be Equal As Strings    ${output}    active    ${service} still runs
    END
