# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require 'net/http'
require 'uri'
require 'json'
require "net/https"

class Watson
  @@sessionId = ""
  
  def initialize
    Rails.logger.debug 'Watson-initialize'
    
    body = ""
    json_response = send_api("", body)
    if json_response
      @@sessionId = json_response["session_id"]
     end
#    api_request_chat
    
#    @hostname = Rails.configuration.x.brightpattern_hostname
#    @appId = Rails.configuration.x.brightpattern_appId
#    @clientId = Rails.configuration.x.brightpattern_clientId
    
  end
  
  #API送付 - 共通処理
  def send_api(api_opt, body, post = true)
    Rails.logger.debug 'Watson-send_api'
    
    json_response = {}
      
    uri = URI.parse("https://gateway-tok.watsonplatform.net/assistant/api/v2/assistants/e65ae379-0d2d-4cd7-800c-c30da8d805bf/sessions" + api_opt + "?version=2019-02-28")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = 'Basic YXBpa2V5OlVHbEJ1d3YwT0V6Rl9rbEswN3NHRzZPMnlHaDRPWmJjZldRTjkzX1pUcXBC'
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

    cmd = "curl -u 'apikey:UGlBuwv0OEzF_klK07sGG6O2yGh4OZbcfWQN93_ZTqpB' -X POST 'https://gateway-tok.watsonplatform.net/assistant/api/v2/assistants/e65ae379-0d2d-4cd7-800c-c30da8d805bf/sessions?version=2019-02-28'"
    response = %x[ #{cmd} ]
    
    json_response = JSON.parse(response)
    @@sessionId = json_response["session_id"]

    Rails.logger.debug ("SessionID")
    Rails.logger.debug @@sessionId
  
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

    #    if chat_id then
#      responce = api_send_events(chat_id, query)
#    end
    
#    Rails.logger.debug responce.inspect
#    Rails.logger.debug responce.body.inspect

#    cmd = "curl -u \'apikey:UGlBuwv0OEzF_klK07sGG6O2yGh4OZbcfWQN93_ZTqpB\' -X POST -H \'Content-Type:application/json\' -d '{\"input\": {\"text\": \"" + msg + "\"}}' 'https://gateway-tok.watsonplatform.net/assistant/api/v2/assistants/e65ae379-0d2d-4cd7-800c-c30da8d805bf/sessions/" + @@sessionId + "/message?version=2019-02-28'"
#    Rails.logger.debug cmd

#    response = %x[ #{cmd} ]

    Rails.logger.debug json_response

    text = ""

    if json_response
      json_response = JSON.parse(json_response)
      text = json_response["output"]["generic"][0]["text"]
      html = "<script src='//static.midomi.com/corpus/H_Zk82fGHFX/build/js/templates.min.js'></script><div class='h-template h-simple-text'>   <h3 class='h-template-title h-simple-text-title'>" + text + "</h3> </div>" 
    end
    

    response = ""
    if text.blank?
      responce = create_json_to_send(text, html, {})
    end
    Rails.logger.debug responce
    
    return responce
 end
  
  #チャット受信
  def query_getchat(chat_id)
    Rails.logger.debug 'Watson-query_getchat'
    msg = ""
    
    responce = api_get_events(chat_id)

    Rails.logger.debug responce.body.inspect
    responce_body = JSON.parse(responce.body)
    
    msg = ""
    html = ""
    if responce_body["events"]
      for events in responce_body["events"] do
        if events["event"] == "chat_session_message" then
          Rails.logger.debug "Message=" + events["msg"]
          msg = events["msg"]   #とりあえず最後のメッセージ
        end
      end
    
      html = "<script src='//static.midomi.com/corpus/H_Zk82fGHFX/build/js/templates.min.js'></script><div class='h-template h-simple-text'>   <h3 class='h-template-title h-simple-text-title'>" + msg + "</h3> </div>" 
    end
    
    response = {}
    if !msg.blank?
      responce = create_json_to_send(msg, html, {})
    end
    
    return responce
  end
  
  
  def api_send_events(chat_id, query)
    Rails.logger.debug 'Brightpattern-api_send_events'
    Rails.logger.debug chat_id

    body = JSON.dump({
      "events" => [
        {
          "event" => "chat_session_message",
          "msg" => query
        }
      ]
    })

    return send_api("/" + chat_id + "/events", body)
  end
  
  def api_get_events(chat_id)
    Rails.logger.debug 'Watson-api_get_events'
    Rails.logger.debug chat_id
    
    body = nil
    return send_api("/" + chat_id + "/events", body, false)
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
