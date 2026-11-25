*** Settings ***
Library    SSHLibrary
Resource    api.resource
Resource    matrix.resource
Suite Teardown    Configure matrix with    "encryption_enabled": true

*** Variables ***
${megolm}    {"algorithm":"m.megolm.v1.aes-sha2"}

*** Keywords ***
Client well-known
    ${out} =    Execute Command    curl -sk -H "Host: ${synapse_host}" https://127.0.0.1/.well-known/matrix/client
    ${wellknown} =    Evaluate    json.loads($out) if $out.startswith('{') else {}    modules=json
    RETURN    ${wellknown}

Private room of user1
    [Arguments]    ${initial_state}=[]
    ${room} =    Synapse    POST    /createRoom    {"preset":"private_chat","initial_state":${initial_state}}    token=${token1}
    Dictionary Should Contain Key    ${room}    room_id
    RETURN    ${room['room_id']}

Encryption of
    [Arguments]    ${room}
    ${state} =    Synapse    GET    /rooms/${room}/state/m.room.encryption    token=${token1}
    RETURN    ${state}

*** Test Cases ***
Check encryption is allowed by default
    ${config} =    Run task    module/${module_id}/get-configuration    {}
    Should Be True    ${config['encryption_enabled']}
    ${wellknown} =    Client well-known
    Dictionary Should Not Contain Key    ${wellknown}    io.element.e2ee
    ${room} =    Private room of user1    [{"type":"m.room.encryption","state_key":"","content":${megolm}}]
    Set Suite Variable    ${encrypted_room}    ${room}
    ${state} =    Encryption of    ${room}
    Should Be Equal    ${state['algorithm']}    m.megolm.v1.aes-sha2

Check encryption can be disabled
    Configure matrix with    "encryption_enabled": false
    ${config} =    Run task    module/${module_id}/get-configuration    {}
    Should Not Be True    ${config['encryption_enabled']}
    ${wellknown} =    Client well-known
    Should Be True    ${wellknown['io.element.e2ee']['force_disable']}
    Should Not Be True    ${wellknown['io.element.e2ee']['default']}

Check a new room drops the requested encryption
    # Element X and Cinny ignore the well-known, Synapse creates the room in clear text
    ${room} =    Private room of user1    [{"type":"m.room.encryption","state_key":"","content":${megolm}}]
    Set Suite Variable    ${clear_room}    ${room}
    ${state} =    Encryption of    ${room}
    Should Be Equal    ${state['errcode']}    M_NOT_FOUND

Check encryption cannot be turned on in a room
    ${response} =    Synapse    PUT    /rooms/${clear_room}/state/m.room.encryption/    ${megolm}    token=${token1}
    Should Be Equal    ${response['errcode']}    M_FORBIDDEN
    Should Contain    ${response['error']}    End-to-end encryption is disabled

Check an encrypted room can still be upgraded
    # The upgrade copies the encryption of the old room
    ${response} =    Synapse    POST    /rooms/${encrypted_room}/upgrade    {"new_version":"12"}    token=${token1}
    Dictionary Should Contain Key    ${response}    replacement_room    ${response}
    ${state} =    Encryption of    ${response['replacement_room']}
    Should Be Equal    ${state['algorithm']}    m.megolm.v1.aes-sha2

Check encryption can be enabled again
    Configure matrix with    "encryption_enabled": true
    ${wellknown} =    Client well-known
    Dictionary Should Not Contain Key    ${wellknown}    io.element.e2ee
    ${response} =    Synapse    PUT    /rooms/${clear_room}/state/m.room.encryption/    ${megolm}    token=${token1}
    Dictionary Should Contain Key    ${response}    event_id    ${response}
