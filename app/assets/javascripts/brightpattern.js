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
    
    this.requestApi = function(callback){
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
        this.sendApi("", json_body, true, this.successRequesApi, callback);
    };
    
    this.successRequesApi = function(){
        console.log("sucessRequesApi");
        var chat_id = "";
        var response = this.response;
        if(this.status === 200){
            var json_response = JSON.parse(response);
            if ('chat_id' in json_response) {
                chat_id = json_response["chat_id"];
            }
        }
        this.callback(chat_id);
    };
    
    this.errorSendApi = function(){
        console.log(this.status);
        console.log("error!");
    };
    
    this.sendChat = function(msg, chat_id, callback){
        console.log("sendChat");
        var body = {
          "events": [{
              "event": "chat_session_message",
              "msg": msg
          }]
        };
        json_body = JSON.stringify(body);
        this.sendApi("/" + chat_id + "/events", json_body, true, this.successSendChat, callback);
    };

    this.successSendChat = function(){
        console.log("successSendChat");
        if(this.status === 200){
            this.callback();
        }        
    };    
    
    this.getChat = function(chat_id, callback){
        console.log("getChat");
        body = null;
        this.sendApi("/" + chat_id + "/events", body, false, this.successGetChat, callback);
    };
    
    this.successGetChat = function(){
        console.log("successGetChat");
        console.log(this.response);
        var response = this.response;
        var msg = "";
        if ( this.status === 200 ){
            var json_response = JSON.parse(response);
            if ('events' in json_response) {
                var len = json_response["events"].length;
                for ( var i = 0;  i < len; i++ ) {
                    if ( json_response["events"][i]['event'] === "chat_session_message"){
                        msg = json_response["events"][i]['msg'];
                    }
                }
            }
        }
//        console.log(msg);
        this.callback(this.status, msg);
    };    

    this.sendApi = function(api_opt, body, isPost, successOnload, callback){
        var url = "https://" + hostname + "/clientweb/api/v1/chats" + api_opt + "?tenantUrl=https://" + hostname + "/";
        console.log("url:" + url);

        var xhr = new XMLHttpRequest();
        if (isPost){
            xhr.open("POST", url, true);
        }else{
            xhr.open("GET", url, true);
        }
        xhr.setRequestHeader("Authorization", "MOBILE-API-140-327-PLAIN appId=\"" + appId + "\", clientId=\"" + clientId + "\"");
        xhr.onload = successOnload;
        xhr.onerror = this.errorSendApi;
        if( callback !== null ){
            xhr.callback = callback;
        }
        
        xhr.send(body);
    };
};
