# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require 'net/http'
require 'uri'
require 'json'
require "base64"

class Watson
  @@sessionId = ""
  
  def initialize
    Rails.logger.debug 'Watson-initialize'
    
    @assistantId = "e65ae379-0d2d-4cd7-800c-c30da8d805bf"
    @watsonUrl = "https://gateway-tok.watsonplatform.net/assistant/api"
    
    @apikey = "UGlBuwv0OEzF_klK07sGG6O2yGh4OZbcfWQN93_ZTqpB"
    basic_enc   = Base64.urlsafe_encode64(apikey) 
    Rails.logger.debug("---ENC---")
    Rails.logger.debug basic_enc
    
#    @hostname = Rails.configuration.x.brightpattern_hostname
#    @appId = Rails.configuration.x.brightpattern_appId
#    @clientId = Rails.configuration.x.brightpattern_clientId
    
  end
  
  #API送付 - 共通処理
  def send_api(api_opt, body, post = true)
    Rails.logger.debug 'Watson-send_api'
    
    json_response = {}
      
    uri = URI.parse(@watsonUrl + "/v2/assistants/" + @assistantId + "/sessions" + api_opt + "?version=2019-02-28")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("apikey", @apikey)
#    request["Authorization"] = 'Basic YXBpa2V5OlVHbEJ1d3YwT0V6Rl9rbEswN3NHRzZPMnlHaDRPWmJjZldRTjkzX1pUcXBC'
    request['Content-Type'] = request['Accept'] = 'application/json'
    if body
      request.body = body
    end

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') { |http|
      http.request(request)
    }    
    
    Rails.logger.debug("---REQUEST---")
    Rails.logger.debug uri
    Rails.logger.debug request

    Rails.logger.debug("---RESPONSE---")
    if response
      Rails.logger.debug response
      Rails.logger.debug response.body
      Rails.logger.debug response.code
      json_response = JSON.parse(response.body)
    end

    return json_response

  end
  
  # チャット開始
  def api_request_chat
    Rails.logger.debug 'Watson-api_request_chat'

    body = ""
    json_response = send_api("", body)
    if json_response
      @@sessionId = json_response["session_id"]
     end
  
    return json_response
  end
  
  # チャット送信
  def query_sendchat(msg)
    Rails.logger.debug 'Watson-query_sendchat'
    
    json_response = {}
    if @@sessionId
      body = "{\"input\": {\"text\": \"" + msg + "\"}}"
      json_response = send_api("/" + @@sessionId + "/message", body)
    end

    Rails.logger.debug json_response

    text = ""

    if json_response
      text = json_response["output"]["generic"][0]["text"]
      html = "<script src='//static.midomi.com/corpus/H_Zk82fGHFX/build/js/templates.min.js'></script><div class='h-template h-simple-text'>   <h3 class='h-template-title h-simple-text-title'>" + text + "</h3> </div>" 
    end
    
    response = ""
    if !text.blank?
      response = create_json_to_send(text, html, {})
    end
    
    return response
  end
    
  def create_json_to_send(text, html, expression)
    Rails.logger.debug("Watson-create_json_to_send")

    answer_body = {
        "answer": text,
        "instructions": {
            "expressionEvent": [
              expression
            ],
            "emotionalTone": [
                {
                    "tone": "happiness", # desired emotion in lowerCamelCase
                    "value": 0.5, # number, intensity of the emotion to express between 0.0 and 1.0 
                    "start": 2, # number, in seconds from the beginning of the utterance to display the emotion
                    "duration": 4, # number, duration in seconds this emotion should apply
                    "additive": true, # boolean, whether the emotion should be added to existing emotions (true), or replace existing ones (false)
                    "default": true # boolean, whether this is the default emotion 
                }
            ],
            "displayHtml": {
                "html": html
        }
    }
    }

    body = {
        "answer": JSON.generate(answer_body),
        "matchedContext": "",
#          "conversationPayload": houndify_conversation_state,
        "conversationPayload": "",
    }
    return body
  end
  
end
