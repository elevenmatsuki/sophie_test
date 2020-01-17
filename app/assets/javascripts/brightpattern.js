/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var BrightPattern = function(){
    var hostname = "cbadev.brightpattern.com";
    var appId = "e7926a805d904b11a21dbe114beaf098";
    var clientId = "WebChat";

    this.chat_id = "";
    this.requestApi = function(){
        var body = {
            "phone_number": "",
            "from": "",
            "parameters": {
                "email": "info@cba-japan.com",
                "last_name": "",
                "first_name": "",
                "account_number": "",
                "phone_number": "",
                "subject": "TEST SUBJECT",
                "logging": "",
                "location": {},
                "user_platform": {
                    "browser": "Chrome 78.0.3904.108",
                    "os": "Windows 10 64-bit",
                    "description": "Chrome 78.0.3904.108 on Windows 10 64-bit"
                },
            },   
        };
        json_body = JSON.stringify(body);
        console.log(json_body);
        this.sendApi("", json_body);
    }
    
    this.sendApi = function(api_opt, body){
        var url = "https://" + hostname + "/clientweb/api/v1/chats" + api_opt + "?tenantUrl=https://" + hostname + "/"
        
        var xhr = new XMLHttpRequest();
        xhr.open("POST", url);
//        request["Authorization"] = "MOBILE-API-140-327-PLAIN appId=\"" + appId + "\", clientId=\"" + clientId + "\""

        xhr.setRequestHeader("Authorization", "MOBILE-API-140-327-PLAIN appId=\"" + appId + "\", clientId=\"" + clientId + "\"");
//        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.send(body);
        
        xhr.onload = function (e){
            console.log(xhr.status);
            console.log("success!");
            console.log(xhr.responseText);
        };

        xhr.onerror = function(e){
            console.log(xhr.status);
            console.log("error!");
        };
        
    };
};
