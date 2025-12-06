*** Settings ***
Library    RequestsLibrary
Library    String
Library    Collections
Library    OperatingSystem

Resource   ../TestData/basic_data.robot


*** Variables ***
${BASE_URL}    https://reqres.in
${API_KEY}     reqres-free-v1 
#${API_KEY}     reqres_b7e43309364946d48b2ddc83ae17f28a
${userdata_2_json_file_name}    userdata_2.json
${Create_User_Request_File}     Create_User_Request.json
${Create_User_Response_File}    Create_User_Response.json

*** Test Cases ***
Validate_get_user_details
    ${headers}=    Create Dictionary    x-api-key=${API_KEY}    Content-Type=application/json
    Create Session    reqres_session    ${BASE_URL}    headers=${headers}    verify=True
    ${resp}=    GET On Session    reqres_session    /api/users/2
    Status Should Be    200    ${resp}
    
    Log To Console     ${resp.status_code}
    Log To Console     ${resp.reason}
    Log To Console     ${resp.json()}
    
    ${json_file_path}=    Catenate    SEPARATOR=/    ${CURDIR}    ..    TestData    ${userdata_2_json_file_name}
    ${json_file_content}=    OperatingSystem.Get File    ${json_file_path}
    ${json_file_content_json}=    Evaluate    json.loads('''${json_file_content}''')    json
    Log    ${json_file_content_json}
    Dictionaries Should Be Equal    ${resp.json()['data']}    ${json_file_content_json['data']}

Validate_create_user
    RequestsLibrary.Create Session    reqes_create_session    ${base_url}
    ${header_val}=    Create Dictionary    x-api-key=${API_KEY}     Content-Type=application/json     Create Session    reqes_create_session    ${BASE_URL}       verify=True
    

    #------------- Read json body -------------
    ${json_file_path}=        Catenate    SEPARATOR=/    ${CURDIR}    ..    TestData    ${Create_User_Request_File}
    ${json_file_content}=     OperatingSystem.Get File    ${json_file_path}
    ${json_file_content_body}=    Evaluate    json.loads('''${json_file_content}''')    json
    #------------------------------------------
    
    ${response_obj}=    RequestsLibrary.POST On Session    reqes_create_session      /api/users    headers=${header_val}    json=${json_file_content_body}
    
    RequestsLibrary.Status Should Be    201
    Should Be Equal As Strings    ${response_obj.reason}    Created

    ${actual_response}=    Set Variable    ${response_obj.json()}
    Dictionary Should Contain Key    ${actual_response}    id
    Dictionary Should Contain Key    ${actual_response}    createdAt

    Remove From Dictionary    ${actual_response}    id
    Remove From Dictionary    ${actual_response}    createdAt

    ${json_file_path}=        Catenate    SEPARATOR=    ${EXECDIR}/${Create_User_Response_File}
    ${json_file_content}=     OperatingSystem.Get File    ${json_file_path}
    ${expected_response}=     Evaluate    json.loads('''${json_file_content}''')    json
    
    Dictionaries Should Be Equal    ${actual_response}        ${expected_response}