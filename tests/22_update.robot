*** Settings ***
Library    SSHLibrary
Resource    api.resource
Resource    matrix.resource
# 10_install installed the stable release in this scenario; move it to the
# image under test and check nothing created before is lost.
Suite Setup    Skip If    '${SCENARIO}' != 'update'    scenario is ${SCENARIO}, nothing to update

*** Test Cases ***
Update matrix to the image under test
    ${rc} =    Execute Command
    ...    api-cli run update-module --data '{"force":true,"module_url":"${IMAGE_URL}","instances":["${module_id}"]}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0
    # Without it the checks below could pass against the stable release
    ${image} =    Execute Command    redis-cli hget module/${module_id}/environment IMAGE_URL
    Should Be Equal    ${image.strip()}    ${IMAGE_URL}

Check matrix works after the update
    Matrix is running
    Get a token for    user1

Check the matrix pod runs after the update
    Matrix pod is running

Check the services listen on localhost only after the update
    Services listen on localhost only

Check the configuration survives the update
    ${config} =    Run task    module/${module_id}/get-configuration    {}
    Should Be Equal    ${config['synapse_domain_name']}    ${synapse_host}
    Should Be Equal    ${config['ldap_domain']}    ${user_domain}

Check the message and the session survive the update
    # The token of user2 was issued before the update
    user2 reads the message of user1
