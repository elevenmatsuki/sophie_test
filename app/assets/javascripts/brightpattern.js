/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var BrightPattern = function(){
    this.chat_id = "";
    this.requestApi = function(chat_id){
        this.chat_id = chat_id;
    }
    
    this.sendApi = function(msg){
        console.log("BrightPattern API: " + this.chat_id);
        console.log("BrightPattern API: " + msg);
    };
};
