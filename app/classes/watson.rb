# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require 'net/http'
require 'uri'
require 'json'

class Watson
  
  def initialize
    Rails.logger.debug 'Watson-initialize'
    
    body = ""
    response = send_api("sessions", body)
    
#    @hostname = Rails.configuration.x.brightpattern_hostname
#    @appId = Rails.configuration.x.brightpattern_appId
#    @clientId = Rails.configuration.x.brightpattern_clientId
    Rails.logger.debug("---RESPONSE2---")
    Rails.logger.debug (response)
    Rails.logger.debug (response.code)
    
  end
  
  #API送付 - 共通処理
  def send_api(api_opt, body, post = true)
    Rails.logger.debug 'Watson-send_api'
      
#    baseurl = "https://gateway-tok.watsonplatform.net/assistant/api/v2/assistants/"
#    baseurl = "https://gateway-tok.watsonplatform.net/assistant/api/v2/assistants/"
#    baseurl = "https://gateway-tok.watsonplatform.net/v2/assistants/"
 #   assistant_id = "e65ae379-0d2d-4cd7-800c-c30da8d805bf"
#    clientId = "WebChat"

#    uri = URI.parse("https://gateway-tok.watsonplatform.net/assistant/api/v2/assistants/537a4514-20cc-40f3-a26d-a1c654fa8b3c/sessions?version=2019-02-28")
#    uri = URI.parse(baseurl + assistant_id + "/" + api_opt + "?version=2019-02-28")
#    Rails.logger.debug (uri)
#    if post 
#      request = Net::HTTP::Post.new(uri)
#    else
#      request = Net::HTTP::Get.new(uri)
#    end
#    request.basic_auth("apikey", "UGlBuwv0OEzF_klK07sGG6O2yGh4OZbcfWQN93_ZTqpB")
#    request.content_type = "text/plain"
#    request.content_type = "application/json"
#    request["Authorization"] = "MOBILE-API-140-327-PLAIN appId=\"" + appId + "\", clientId=\"" + clientId + "\""

    uri = URI.parse("https://gateway-tok.watsonplatform.net/assistant/api/v2/assistants/e65ae379-0d2d-4cd7-800c-c30da8d805bf/sessions?version=2019-02-28")
    request = Net::HTTP::Post.new(uri)
    request.basic_auth("apikey", "UGlBuwv0OEzF_klK07sGG6O2yGh4OZbcfWQN93_ZTqpB")

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    if body
      request.body = body
      Rails.logger.debug("---BODY---")
    end

    Rails.logger.debug("---REQUEST---")
    Rails.logger.debug request.inspect
    Rails.logger.debug uri.inspect

    Rails.logger.debug("---RESPONSE---")
    if response
      Rails.logger.debug response.inspect
      Rails.logger.debug response.body
    end

    return response

  end
  
  # チャット開始
  def api_request_chat
    Rails.logger.debug 'Watson-api_request_chat'

    body = JSON.dump({
      "phone_number" => "",
      "from" => "",
      "parameters" => {
        "email" => "info@cba-japan.com",
        "last_name" => "",
        "first_name" => "",
        "account_number" => "",
        "phone_number" => "",
        "subject" => "TEST SUBJECT",
        "logging" => "",
        "location" => {},
        "user_platform" => {
          "browser" => "Chrome 78.0.3904.108",
          "os" => "Windows 10 64-bit",
          "description" => "Chrome 78.0.3904.108 on Windows 10 64-bit"
        }
      }
    })
  
    return send_api("", body)
  end
  
  # チャット送信
  def query_sendchat(chat_id, query)
    Rails.logger.debug 'Watson-query_sendchat'
    
    if chat_id then
      responce = api_send_events(chat_id, query)
    end
    
    Rails.logger.debug responce.inspect
    Rails.logger.debug responce.body.inspect

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
