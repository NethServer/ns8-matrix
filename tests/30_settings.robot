*** Settings ***
Library    SSHLibrary
Resource    api.resource
Resource    matrix.resource

*** Variables ***
${other_domain}    other.dom.test

*** Keywords ***
Save the smarthost
    ${smarthost} =    Run task    cluster/get-smarthost    {}
    Set Test Variable    ${saved_smarthost}    ${smarthost}

Set the smarthost
    [Arguments]    ${username}    ${password}
    # Disabled, so set-smarthost does not try to reach the server, but Synapse still gets the values
    ${payload} =    Evaluate    json.dumps({"host": "smtp.example.org", "port": 587, "username": $username, "password": $password, "enabled": False, "encrypt_smtp": "starttls", "tls_verify": False})    modules=json
    Run task    cluster/set-smarthost    ${payload}

Restore the smarthost
    ${payload} =    Evaluate    json.dumps({k: v for k, v in $saved_smarthost.items() if k in ("host", "port", "username", "password", "enabled", "encrypt_smtp", "tls_verify")})    modules=json
    Run task    cluster/set-smarthost    ${payload}
    # smarthost-changed restarts Synapse: wait for it, or the next test gets a 502 from Traefik
    ${username} =    Evaluate    $saved_smarthost['username'] or None
    ${password} =    Evaluate    $saved_smarthost['password'] if $saved_smarthost['username'] else None
    Wait Until Keyword Succeeds    2 minutes    5 seconds    Synapse SMTP credentials are    ${username}    ${password}
    Wait Until Keyword Succeeds    30 times    5 seconds    Synapse answers

Synapse SMTP credentials are
    [Arguments]    ${username}    ${password}
    ${out} =    Execute Command    runagent -m ${module_id} podman exec synapse python3 -c 'import json, yaml; e = yaml.safe_load(open("/data/config/homeserver.yaml"))["email"]; print(json.dumps([e["smtp_user"], e["smtp_pass"]]))'
    ${values} =    Evaluate    json.loads($out)    modules=json
    Should Be Equal    ${values[0]}    ${username}
    Should Be Equal    ${values[1]}    ${password}

Element route host
    ${route} =    Run task    module/traefik1/get-route    {"instance":"${module_id}-element"}
    ${host} =    Evaluate    $route.get('host', '')
    RETURN    ${host}

*** Test Cases ***
Check Synapse skips SMTP authentication without credentials
    [Setup]    Save the smarthost
    Set the smarthost    ${EMPTY}    ${EMPTY}
    Wait Until Keyword Succeeds    2 minutes    5 seconds    Synapse SMTP credentials are    ${NONE}    ${NONE}
    [Teardown]    Restore the smarthost

Check Synapse reads SMTP credentials with reserved characters
    [Setup]    Save the smarthost
    # Quotes, YAML markers and a placeholder that must not be expanded again
    ${password} =    Evaluate    'p@ss: #"1" ' + chr(36) + '{SYNAPSE_PORT}'
    Set the smarthost    bob@example.org    ${password}
    Wait Until Keyword Succeeds    2 minutes    5 seconds    Synapse SMTP credentials are    bob@example.org    ${password}
    Wait Until Keyword Succeeds    30 times    5 seconds    Synapse answers
    [Teardown]    Restore the smarthost

Check federation is disabled by default
    ${code} =    HTTP status of    /_matrix/federation/v1/version
    Should Be Equal    ${code}    404
    ${code} =    HTTP status of    /.well-known/matrix/server
    Should Be Equal    ${code}    404

Check federation can be enabled
    Configure matrix with    "federation": true, "federation_whitelist": ["example.org"]
    ${code} =    HTTP status of    /_matrix/federation/v1/version
    Should Be Equal    ${code}    200
    ${output} =    Execute Command    curl -sk -H "Host: ${synapse_host}" https://127.0.0.1/.well-known/matrix/server
    ${wellknown} =    Evaluate    json.loads($output)    modules=json
    Should Be Equal    ${wellknown['m.server']}    ${synapse_host}:443

Check the TURN server settings
    Configure matrix with    "turn_uris": ["turn:turn.example.org:3478?transport=udp"], "turn_shared_secret": "@secret"
    ${response} =    Synapse    GET    /voip/turnServer    token=${token1}
    Should Be Equal    ${response['uris'][0]}    turn:turn.example.org:3478?transport=udp
    Dictionary Should Contain Key    ${response}    password
    ${config} =    Run task    module/${module_id}/get-configuration    {}
    Should Be True    ${config['turn_shared_secret_set']}
    Dictionary Should Not Contain Key    ${config}    turn_shared_secret
    # An empty secret keeps the stored one
    Configure matrix with    "turn_uris": ["turn:turn.example.org:3478?transport=udp"], "turn_shared_secret": ""
    ${response} =    Synapse    GET    /voip/turnServer    token=${token1}
    Dictionary Should Contain Key    ${response}    password

Check the TURN secret is required
    Configure matrix with    "turn_uris": [], "turn_clear_secret": true
    ${rc} =    Execute Command    runagent -m ${module_id} test -e turn.env    return_stdout=False    return_rc=True
    Should Not Be Equal As Integers    ${rc}    0
    Run task    module/${module_id}/configure-module    {${base_config}, "turn_uris": ["turn:turn.example.org"]}    rc_expected=2    decode_json=${FALSE}

Check the media settings
    Configure matrix with    "max_upload_size_mb": 100, "local_media_lifetime_days": 30, "log_level": "WARNING"
    ${output} =    Execute Command    runagent -m ${module_id} grep -E "^max_upload_size|local_media_lifetime" synapse-config/homeserver.yaml
    Should Contain    ${output}    max_upload_size: 100M
    Should Contain    ${output}    local_media_lifetime: "30d"
    ${output} =    Execute Command    curl -sk -H "Host: ${synapse_host}" -H "Authorization: Bearer ${token1}" https://127.0.0.1/_matrix/client/v1/media/config
    ${media} =    Evaluate    json.loads($output)    modules=json
    Should Be Equal As Integers    ${media['m.upload.size']}    104857600

Check the Element client can be disabled and enabled again
    Configure matrix with    "element_domain_name": ""
    ${host} =    Element route host
    Should Be Empty    ${host}
    ${output} =    Execute Command    runagent -m ${module_id} systemctl --user is-active element-web
    Should Not Be Equal As Strings    ${output}    active
    Configure matrix with    "element_domain_name": "${element_host}"
    ${host} =    Element route host
    Should Be Equal    ${host}    ${element_host}
    Wait Until Keyword Succeeds    30 times    5 seconds    Service is active    element-web

Check a change of LDAP domain
    ${response} =    Run task    cluster/add-internal-provider    {"image":"openldap","node":1}
    ${mid_other} =    Set Variable    ${response['module_id']}
    Run task    module/${mid_other}/configure-module    {"domain":"${other_domain}","admuser":"admin","admpass":"${user_password}","provision":"new-domain"}
    Run task    module/${mid_other}/add-user    {"user":"user3","display_name":"User Three","password":"${user_password}"}
    Configure matrix with    "ldap_domain": "${other_domain}"
    ${response} =    Log in    user1
    Should Be Equal    ${response['errcode']}    M_FORBIDDEN    user1 of ${user_domain} must not log in any more
    Get a token for    user3
    # Synapse checks the password only at login: a session opened before stays valid
    ${response} =    Synapse    GET    /account/whoami    token=${token1}
    Should Be Equal    ${response['user_id']}    @user1:${synapse_host}
    [Teardown]    Run Keywords
    ...    Configure matrix with    "ldap_domain": "${user_domain}"
    ...    AND    Run task    cluster/remove-internal-domain    {"domain":"${other_domain}"}
