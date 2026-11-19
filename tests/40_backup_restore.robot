*** Settings ***
Library    SSHLibrary
Resource    api.resource
Resource    matrix.resource
Suite Teardown    Remove the test backup

*** Keywords ***
Remove the test backup
    # Runs even when a step failed half way, so check what was created
    ${bid} =    Get Variable Value    ${backup_id}    ${NONE}
    IF    $bid is not None
        Run task    cluster/remove-backup    {"id":${bid}}
    END
    ${created} =    Get Variable Value    ${repository_created}    ${FALSE}
    IF    ${created}
        Run task    cluster/remove-backup-repository    {"id":"${repository}"}
    END

Module environment
    [Arguments]    ${name}
    ${out} =    Execute Command    runagent -m ${module_id} printenv ${name}
    RETURN    ${out.strip()}

The restore has run
    # Without it the checks below would pass against the old module
    Should Be True    ${restored}    the restore did not complete

*** Test Cases ***
Record the data before the backup
    ${fingerprint} =    Matrix fingerprint
    ${uuid} =    Module environment    MODULE_UUID
    ${node} =    Module environment    NODE_ID
    Set Suite Variable    ${fingerprint_before}    ${fingerprint}
    Set Suite Variable    ${module_uuid}    ${uuid}
    Set Suite Variable    ${module_node}    ${node}
    Set Suite Variable    ${old_module_id}    ${module_id}
    Set Suite Variable    ${restored}    ${FALSE}

Use the node local backup repository
    # A repository URL must be unique: reuse the node's one if it exists
    ${ip} =    Execute Command    redis-cli hget node/${module_node}/vpn ip_address
    ${url} =    Set Variable    webdav:http://${ip.strip()}:4694
    ${repos} =    Run task    cluster/list-backup-repositories    {}
    ${found} =    Evaluate    [r['id'] for r in $repos['repositories'] if r['url'] == $url]
    IF    ${found}
        Set Suite Variable    ${repository}    ${found}[0]
        Set Suite Variable    ${repository_created}    ${FALSE}
    ELSE
        ${out} =    Run task    cluster/add-backup-repository
        ...    {"provider":"cluster","name":"matrix-test","url":"${url}","password":"","parameters":{}}
        Set Suite Variable    ${repository}    ${out}[id]
        Set Suite Variable    ${repository_created}    ${TRUE}
    END

Back up matrix
    # run-backup skips a disabled backup, so enable it on a far schedule
    ${bid} =    Run task    cluster/add-backup
    ...    {"name":"matrix-test","instances":["${module_id}"],"repository":"${repository}","schedule":"*-12-31 03:17:00","retention":1,"enabled":true}
    Set Suite Variable    ${backup_id}    ${bid}
    # Synchronous: it returns once every node has finished its part
    Run task    cluster/run-backup    {"id":${backup_id}}
    ${snapshots} =    Run task    cluster/read-backup-snapshots
    ...    {"repository":"${repository}","path":"matrix/${module_uuid}"}
    Should Not Be Empty    ${snapshots}
    Set Suite Variable    ${snapshot}    ${snapshots}[-1][id]

Restore matrix in place
    ${out} =    Run task    cluster/restore-module
    ...    {"repository":"${repository}","path":"matrix/${module_uuid}","snapshot":"${snapshot}","node":${module_node},"replace":true}
    # Store the new id first: the old instance is gone, so later suites must target this one
    Set Global Variable    ${module_id}    ${out}[module_id]
    Set Suite Variable    ${restored}    ${TRUE}
    Should Be Equal    ${out}[module_uuid]    ${module_uuid}
    Should Not Be Equal    ${out}[module_id]    ${old_module_id}
    ${rc} =    Execute Command    runagent -m ${old_module_id} true
    ...    return_rc=True    return_stdout=False
    Should Not Be Equal As Integers    ${rc}    0    ${old_module_id} must be gone after a replace

Matrix runs again after the restore
    [Setup]    The restore has run
    Matrix is running
    Read the Synapse port

The database is restored as it was
    [Setup]    The restore has run
    ${fingerprint} =    Matrix fingerprint
    Should Be Equal    ${fingerprint}    ${fingerprint_before}

The configuration is restored
    [Setup]    The restore has run
    ${config} =    Run task    module/${module_id}/get-configuration    {}
    Should Be Equal    ${config['synapse_domain_name']}    ${synapse_host}
    Should Be Equal    ${config['ldap_domain']}    ${user_domain}
    Should Be Equal    ${config['element_domain_name']}    ${element_host}

Sessions and messages survive the restore
    [Setup]    The restore has run
    # Tokens were issued before the backup
    user2 reads the message of user1
    ${sent} =    Synapse    PUT    /rooms/${room_id}/send/m.room.message/after-restore    {"msgtype":"m.text","body":"after restore"}    token=${token1}
    Dictionary Should Contain Key    ${sent}    event_id
