*** Settings ***
Library    SSHLibrary
Resource    matrix.resource

*** Variables ***
${ADMIN_USER}    admin
${ADMIN_PASSWORD}    Nethesis,1234

*** Keywords ***
Login to cluster-admin
    New Page    https://${NODE_ADDR}/cluster-admin/
    Fill Text    text="Username"    ${ADMIN_USER}
    Click    button >> text="Continue"
    Fill Text    text="Password"    ${ADMIN_PASSWORD}
    Click    button >> text="Log in"
    Wait For Elements State    css=#main-content    visible    timeout=10s

*** Test Cases ***
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

Element and Cinny show their login form
    [Tags]    ui
    # The apps run their JavaScript, read config.json and reach Synapse
    # before they draw the form, which a curl test cannot check.
    Import Library    Browser
    New Browser    chromium    headless=True    args=["--host-resolver-rules=MAP *.dom.test ${NODE_ADDR}"]
    New Context    ignoreHTTPSErrors=True
    New Page    https://${element_host}/#/login
    Wait For Elements State    id=mx_LoginForm_password    visible    timeout=60s
    Get Text    body    not contains    misconfigured
    Take Screenshot    filename=${OUTPUT DIR}/browser/screenshot/3._Element.png
    New Page    https://${cinny_host}/
    Wait For Elements State    css=input[name=passwordInput]    visible    timeout=60s
    Get Text    body    not contains    Failed to connect
    Take Screenshot    filename=${OUTPUT DIR}/browser/screenshot/4._Cinny.png
    Close Browser
