*** Settings ***
Library    SeleniumLibrary
Resource   ../ProjectConfig/config.robot

Suite Setup       perform_setup_operation
Suite Teardown    perform_teardown_operation

*** Variables ***
${testing_type}    web

*** Keywords ***
perform_setup_operation
    Log    performing suite setup
    IF    '${testing_type}' == 'web'
    SeleniumLibrary.Open Browser    ${application_url}      ${browser_type}
    SeleniumLibrary.Maximize Browser Window
    SeleniumLibrary.Set Selenium Implicit Wait    10S
    SeleniumLibrary.Set Selenium Timeout    10S
    
    END
    IF    '${testing_type}' == 'api'
        Log    performing suite setup    for    api    testing
    END
perform_teardown_operation
    Log    performing suite teardown
    IF    '${testing_type}' == 'web'
        Log    performing api suite teardown
    END 
    IF    '${testing_type}' == 'api'
        Log    performing api suite teardown
    END
