/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var RequestParam = function(){
    this.api_opt = "";
    this.body;
    this.isPost = true;
    this.callbackFunction;
};

var BrightPattern = function(){
    var hostname = "cbadev.brightpattern.com";
    var appId = "e7926a805d904b11a21dbe114beaf098";
    var clientId = "WebChat";

    this.chat_id = "";
    
    this.main = function(){
        this.requestApi();
    };
    
    this.requestApi = function(){
        console.log("requestApi");
        var body = [{
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
                }
            }
        }];
        json_body = JSON.stringify(body);
        this.sendApi("", json_body, true, this.successRequesApi, this.sendChat);
        console.log("requestApi-end");
    };
    
    this.successRequesApi = function(){
        console.log("sucessRequesApi");
        console.log("this");
        console.log(this);
        var response = this.response;
        console.log(response);
        var json_response = JSON.parse(response);
        if ('chat_id' in json_response) {
            this.chat_id = json_response["chat_id"];
            console.log("chat_id:" + this.chat_id);
            this.callback();
        }
    };
    
    this.errorSendApi = function(){
        console.log(this.status);
        console.log("error!");
    };
    
    this.sendChat = function(msg){
        console.log("sendChat");
        body = [{
          "events": {
              "event":"chat_session_message",
              "msg": msg
            }
        }];
        json_body = JSON.stringify(body);
        this.sendApi("/" + this.chat_id + "/events", json_body, true, this.successSendChat, null);
        console.log("sendChat-end");
    };

    this.successSendChat = function(){
        console.log("successSendChat");
    };    
    
    this.sendApi = function(api_opt, body, isPost, successOnload, callback){
        var url = "https://" + hostname + "/clientweb/api/v1/chats" + api_opt + "?tenantUrl=https://" + hostname + "/";

        var xhr = new XMLHttpRequest();
        if (isPost){
            xhr.open("POST", url, false);
        }else{
            xhr.open("GET", url, false);
        }
        xhr.setRequestHeader("Authorization", "MOBILE-API-140-327-PLAIN appId=\"" + appId + "\", clientId=\"" + clientId + "\"");
//        xhr.onload = successOnload;
//        xhr.onerror = this.errorSendApi;
/*        if( callback !== null ){
            xhr.callback = callback;
        }
*/
        xhr.send(body);
    };
};
