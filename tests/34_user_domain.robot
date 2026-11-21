*** Settings ***
Library    SSHLibrary
Library    Collections
Resource    api.resource
Resource    matrix.resource
# The user domain is locked once a user logs in, so delegation needs an instance of its own.
# The main instance keeps its user domain equal to its host, like an installation before the setting.
Suite Setup    Install a delegated instance
Suite Teardown    Remove the delegated instance

*** Variables ***
${delegated_host}    matrix2.dom.test
${delegated_domain}    dom.test

*** Keywords ***
Install a delegated instance
    Set Suite Variable    ${main_module_id}    ${module_id}
    # The module allows one instance per node
    ${output}  ${rc} =    Execute Command    add-module --force ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${delegated_id}    ${output.module_id}
    ${payload} =    Evaluate    json.dumps({"synapse_domain_name": $delegated_host, "matrix_server_name": $delegated_domain, "lets_encrypt": False, "ldap_domain": $user_domain})    modules=json
    Run task    module/${delegated_id}/configure-module    ${payload}    decode_json=${FALSE}
    ${port} =    Execute Command    runagent -m ${delegated_id} sh -c 'grep ^SYNAPSE_PORT= config.env | cut -d= -f2'
    Set Suite Variable    ${delegated_port}    ${port.strip()}
    Wait Until Keyword Succeeds    30 times    5 seconds    Delegated Synapse answers

Remove the delegated instance
    Execute Command    remove-module --no-preserve ${delegated_id}

Delegated Synapse answers
    ${rc} =    Execute Command    curl -skf -o /dev/null -H "Host: ${delegated_host}" https://127.0.0.1/_matrix/client/versions
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Delegated configuration
    ${config} =    Run task    module/${delegated_id}/get-configuration    {}
    RETURN    ${config}

Configure the delegated instance with
    [Arguments]    ${extra}    ${rc_expected}=0
    ${payload} =    Evaluate    json.dumps({"synapse_domain_name": $delegated_host, "lets_encrypt": False, "ldap_domain": $user_domain, **json.loads('{' + $extra + '}')})    modules=json
    ${out} =    Run task    module/${delegated_id}/configure-module    ${payload}    rc_expected=${rc_expected}    decode_json=${FALSE}
    # Synapse restarts after a configuration change
    Wait Until Keyword Succeeds    30 times    5 seconds    Delegated Synapse answers
    RETURN    ${out}

Well-known of the user domain
    [Arguments]    ${name}
    ${out} =    Execute Command    curl -skf -H "Host: ${delegated_domain}" https://127.0.0.1/.well-known/matrix/${name}
    Should Not Be Empty    ${out}
    ${response} =    Evaluate    json.loads($out)    modules=json
    RETURN    ${response}

*** Test Cases ***
Check the user domain is free before the first login
    ${config} =    Delegated configuration
    Should Be Equal    ${config['matrix_server_name']}    ${delegated_domain}
    Should Not Be True    ${config['matrix_server_name_locked']}

Check the user domain serves the client well-known
    ${response} =    Well-known of the user domain    client
    Should Be Equal    ${response['m.homeserver']['base_url']}    https://${delegated_host}/

Check the user domain routes
    FOR    ${suffix}    ${path}    IN    -wellknown    /.well-known/matrix    -userdomain    /_matrix
        ${route} =    Run task    module/traefik1/get-route    {"instance":"${delegated_id}${suffix}"}
        Should Be Equal    ${route['host']}    ${delegated_domain}
        Should Be Equal    ${route['path']}    ${path}
    END

Check a user gets an ID on the user domain
    ${address} =    Evaluate    f"10.98.{random.randint(0, 255)}.{random.randint(1, 254)}"    modules=random
    ${out} =    Execute Command    curl -s -X POST -H "X-Forwarded-For: ${address}" -H "Content-Type: application/json" -d '{"type":"m.login.password","identifier":{"type":"m.id.user","user":"user1"},"password":"${user_password}"}' "http://127.0.0.1:${delegated_port}/_matrix/client/v3/login"
    ${response} =    Evaluate    json.loads($out)    modules=json
    Should Be Equal    ${response['user_id']}    @user1:${delegated_domain}

Check the user domain is locked after the first login
    ${config} =    Delegated configuration
    Should Be True    ${config['matrix_server_name_locked']}
    ${out} =    Configure the delegated instance with    "matrix_server_name": "other.${delegated_domain}"    rc_expected=2
    Should Contain    ${out}    matrix_server_name_locked
    ${config} =    Delegated configuration
    Should Be Equal    ${config['matrix_server_name']}    ${delegated_domain}

Check a request without the user domain keeps it
    Configure the delegated instance with    "federation": true
    ${config} =    Delegated configuration
    Should Be Equal    ${config['matrix_server_name']}    ${delegated_domain}
    ${response} =    Wait Until Keyword Succeeds    30 times    5 seconds    Well-known of the user domain    server
    Should Be Equal    ${response['m.server']}    ${delegated_domain}:443

Check the main instance keeps its host as user domain
    ${config} =    Run task    module/${main_module_id}/get-configuration    {}
    Should Be Equal    ${config['matrix_server_name']}    ${synapse_host}
    Should Be True    ${config['matrix_server_name_locked']}
    ${route} =    Run task    module/traefik1/get-route    {"instance":"${main_module_id}-wellknown"}
    Should Be Empty    ${route}
