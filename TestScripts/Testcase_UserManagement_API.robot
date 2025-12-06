*** Settings ***
Library    RequestsLibrary
Library    String
Library    Collections
Library    OperatingSystem
Library    ../Utilities/env_loader.py
Resource   ../TestData/basic_data.robot
Resource   secrets.robot

*** Variables ***
${BASE_URL}    https://reqres.in

*** Test Cases ***
Validate_get_user_details
    ${headers}=    Create Dictionary    x-api-key=${API_KEY}    Content-Type=application/json
    Create Session    reqres_session    ${BASE_URL}    headers=${headers}    verify=True
    ${resp}=    GET On Session    reqres_session    /api/users/2
    Status Should Be    200    ${resp}
    
    Log To Console     status:${resp.status_code}
    Log To Console     ${resp.reason}
    Log To Console     ${resp.json()}
    
    ${json_file_path}=    Catenate    SEPARATOR=/    ${CURDIR}    ..    TestData    ${userdata_2_json_file_name}
    ${json_file_content}=    OperatingSystem.Get File    ${json_file_path}
    ${json_file_content_json}=    Evaluate    json.loads('''${json_file_content}''')    json
    Log    ${json_file_content_json}
    Dictionaries Should Be Equal    ${resp.json()['data']}    ${json_file_content_json['data']}

Validate_create_user_debug
    ${headers}=    Create Dictionary    x-api-key=${API_KEY}    Content-Type=application/json
    Create Session    reqes_create_session    ${BASE_URL}    headers=${headers}    verify=True

    ${json_file_path}=    Catenate    SEPARATOR=/    ${CURDIR}    ..    TestData    ${Create_User_Request_File}
    ${json_file_content}=    OperatingSystem.Get File    ${json_file_path}
    ${json_file_content_body}=    Evaluate    json.loads('''${json_file_content}''')    json

    ${response_obj}=    POST On Session    reqes_create_session    /api/users    json=${json_file_content_body}

    Log To Console    status: ${response_obj.status_code}
    Log To Console    reason: ${response_obj.reason}
    Log To Console    text: ${response_obj.text}
    Log To Console    request.headers: ${response_obj.request.headers}
    Log To Console    request.body: ${response_obj.request.body}

    Status Should Be    201    ${response_obj}

*** Test Cases ***
Validate_PUT_update_user
    # --- prepare headers & session ---
    ${headers}=    Create Dictionary    x-api-key=${API_KEY}    Content-Type=application/json
    Create Session    reqes_update_session    ${BASE_URL}    headers=${headers}    verify=True

    # --- read request body from file ---
    ${json_file_path}=    Catenate    SEPARATOR=/    ${CURDIR}    ..    TestData    ${Update_User_Request_File}
    ${json_file_content}=    OperatingSystem.Get File    ${json_file_path}
    ${json_file_content_body}=    Evaluate    json.loads('''${json_file_content}''')    json

    # --- call API (PUT) ---
    ${response_obj}=    PUT On Session    reqes_update_session    /api/users/2    json=${json_file_content_body}

    Log To Console    status: ${response_obj.status_code}
    Log To Console    reason: ${response_obj.reason}
    Log To Console    response.text: ${response_obj.text}
    Log To Console    request.headers: ${response_obj.request.headers}
    Log To Console    request.body: ${response_obj.request.body}

    # --- asserts ---
    Status Should Be    200    ${response_obj}
    Should Be Equal As Strings    ${response_obj.reason}    OK

    ${actual_response}=    Set Variable    ${response_obj.json()}
    Dictionary Should Contain Key    ${actual_response}    updatedAt

    Remove From Dictionary    ${actual_response}    updatedAt

    # --- load expected response and compare ---
    ${json_file_path}=    Catenate    SEPARATOR=/    ${CURDIR}    ..    TestData    ${Update_User_Response_File}
    ${json_file_content}=    OperatingSystem.Get File    ${json_file_path}
    ${expected_response}=    Evaluate    json.loads('''${json_file_content}''')    json

Validate_Patch_update_user
    RequestsLibrary.Create Session    reqes_create_session    ${base_url}
    ${header_val}=    Create Dictionary    x-api-key=${API_KEY}     Content-Type=application/json

    #------------- Read json body ------------------
    ${json_file_path}=    Catenate    SEPARATOR=/    ${CURDIR}    ..    TestData    ${UpdateP_User_Request_File}
    ${json_file_content}=    OperatingSystem.Get File    ${json_file_path}
    ${json_file_content_body}=    Evaluate    json.loads('''${json_file_content}''')    json
    #------------------------------------------------

    ${response_obj}=    RequestsLibrary.PATCH On Session    reqes_create_session    /api/users/2    headers=${header_val}    json=${json_file_content_body}
  
    RequestsLibrary.Status Should Be    200
    Should Be Equal As Strings    ${response_obj.reason}    OK

    ${actual_response}=    Set Variable    ${response_obj.json()}
    Dictionary Should Contain Key    ${actual_response}    updatedAt

    Remove From Dictionary    ${actual_response}    updatedAt

    #------------- Read expected response ----------
    ${json_file_path}=    Catenate    SEPARATOR=/    ${CURDIR}    ..    TestData    ${UpdateP_User_Response_File}
    ${json_file_content}=    OperatingSystem.Get File    ${json_file_path}
    ${expected_response}=    Evaluate    json.loads('''${json_file_content}''')    json
    #------------------------------------------------
    Log To Console    status: ${response_obj.status_code}
    Log To Console    reason: ${response_obj.reason}
    Log To Console    response.text: ${response_obj.text}
    Log To Console    request.headers: ${response_obj.request.headers}
    Log To Console    request.body: ${response_obj.request.body}

Validate_delete_user
    RequestsLibrary.Create Session    delete_session    ${base_url}
    ${header_val}=    Create Dictionary    x-api-key=${API_KEY}    Content-Type=application/json

    ${response_object}=    RequestsLibrary.DELETE On Session    delete_session    /api/users/2    headers=${header_val}
    
    Log To Console    status:${response_object.status_code}
    Log To Console    ${response_object.reason}
    Log To Console    ${response_object.text}

    RequestsLibrary.Status Should Be    204

    

