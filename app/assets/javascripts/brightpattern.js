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
    this.requestApi = function(chat_id){
        this.chat_id = chat_id;
    }
    
    this.sendApi = function(api_opt){
        var uri = "https://" + hostname + "/clientweb/api/v1/chats" + api_opt + "?tenantUrl=https://" + hostname + "/"
        
        var xhr = new XMLHttpRequest();
        xhr.open("POST", url);
//        request["Authorization"] = "MOBILE-API-140-327-PLAIN appId=\"" + appId + "\", clientId=\"" + clientId + "\""

        xhr.setRequestHeader("Authorization", "MOBILE-API-140-327-PLAIN appId=\"" + appId + "\", clientId=\"" + clientId + "\"");
//        xhr.setRequestHeader("Content-Type", "application/json");
        var response = xhr.send();
        
        xhr.onload = function (e){
            console.log(xhr.status);
            console.log("success!");
        };

        xhr.onerror = function(e){
            console.log(xhr.status);
            console.log("error!");
        };
        
        console.log(response.toString());
    };
};
