*** Settings ***
Library    SSHLibrary
Resource    api.resource
Resource    matrix.resource

*** Test Cases ***
Check LDAP users can log in
    # A fresh Synapse builds its user directory in the background: users and rooms created
    # meanwhile can be left out of it for good
    Wait Until Keyword Succeeds    10 minutes    10 seconds    Synapse background updates are done
    # Synapse limits logins per account, so each user logs in once and keeps its token
    ${token} =    Get a token for    user1
    Set Global Variable    ${token1}    ${token}
    ${token} =    Get a token for    user2
    Set Global Variable    ${token2}    ${token}
    ${response} =    Log in    user1    wrong-password
    Should Be Equal    ${response['errcode']}    M_FORBIDDEN

Send a message in a room
    ${room} =    Synapse    POST    /createRoom    {"name":"upgrade","invite":["@user2:${synapse_host}"]}    token=${token1}
    Set Global Variable    ${room_id}    ${room['room_id']}
    Synapse    POST    /rooms/${room_id}/join    {}    token=${token2}
    ${sent} =    Synapse    PUT    /rooms/${room_id}/send/m.room.message/upgrade-test    {"msgtype":"m.text","body":"${message}"}    token=${token1}
    Dictionary Should Contain Key    ${sent}    event_id
    user2 reads the message of user1

Check the first sync of user2 holds the room
    ${sync} =    Synapse    GET    /sync?timeout=0    token=${token2}
    Dictionary Should Contain Key    ${sync['rooms']['join']}    ${room_id}
    ${bodies} =    Evaluate    [e['content'].get('body') for e in $sync['rooms']['join'][$room_id]['timeline']['events'] if e['type'] == 'm.room.message']
    Should Contain    ${bodies}    ${message}

Check a file can be uploaded and downloaded
    ${out} =    Execute Command    curl -sk -X POST -H "Host: ${synapse_host}" -H "Authorization: Bearer ${token1}" -H "Content-Type: text/plain" --data-binary "file content" "https://127.0.0.1/_matrix/media/v3/upload?filename=note.txt"
    ${upload} =    Evaluate    json.loads($out)    modules=json
    ${media_path} =    Evaluate    $upload['content_uri'][len('mxc://'):]
    ${content} =    Execute Command    curl -sk -H "Host: ${synapse_host}" -H "Authorization: Bearer ${token2}" "https://127.0.0.1/_matrix/client/v1/media/download/${media_path}"
    Should Be Equal    ${content}    file content

Check registration is closed
    ${response} =    Synapse    POST    /register    {"username":"intruder","password":"${user_password}"}
    Should Be Equal    ${response['errcode']}    M_FORBIDDEN

Check the user directory finds a room member
    Wait Until Keyword Succeeds    2 minutes    2 seconds    user1 finds user2 in the directory
