# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require 'net/http'
require 'uri'
require 'json'

class Brightpattern
  
  def initialize
    Rails.logger.debug 'Brightpattern-initialize'
    
    @hostname = Rails.configuration.x.brightpattern_hostname
    @appId = Rails.configuration.x.brightpattern_appId
    @clientId = Rails.configuration.x.brightpattern_clientId
    
#    Rails.logger.debug '===HOSTNAME1==='
#    Rails.logger.debug Rails.configuration.x.brightpattern_hostname
#    Rails.logger.debug Rails.configuration.x.brightpattern_appId
#    Rails.logger.debug Rails.configuration.x.brightpattern_clientId
#    Rails.logger.debug @hostname
#    Rails.logger.debug @appId
#    Rails.logger.debug @clientId
  end
  
  #API送付 - 共通処理
  def send_api(api_opt, body, post = true)
    Rails.logger.debug 'Brightpattern-send_api'
    
    hostname = "cbadev.brightpattern.com"
    appId = "e7926a805d904b11a21dbe114beaf098"
    clientId = "WebChat"

#    Rails.logger.debug '===HOSTNAME2==='
#    Rails.logger.debug @hostname
#    Rails.logger.debug @appId
#    Rails.logger.debug @clientId
    
#    hostname = "cbadevinus.brightpattern.com"
#    appId = "7d4bb4bcf1e44a11a6870a76f791f6de"
#    clientId = "WebChat"
    
    uri = URI.parse("https://" + hostname + "/clientweb/api/v1/chats" + api_opt + "?tenantUrl=https%3A%2F%2F" + hostname + "%2F")
    if post 
      request = Net::HTTP::Post.new(uri)
    else
      request = Net::HTTP::Get.new(uri)
    end
    request["Authorization"] = "MOBILE-API-140-327-PLAIN appId=\"" + appId + "\", clientId=\"" + clientId + "\""

    if body
      request.body = body
      Rails.logger.debug("---BODY---")
    end

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    Rails.logger.debug("---REQUEST---")
    Rails.logger.debug request.inspect
    Rails.logger.debug uri.inspect

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end    
    
    Rails.logger.debug("---RESPONSE---")
    if response
      Rails.logger.debug response.inspect
    end

    return response

  end

  # チャット開始
  def api_request_chat
    Rails.logger.debug 'Brightpattern-api_request_chat'

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
    Rails.logger.debug 'Brightpattern-query_sendchat'
    
    if chat_id then
      responce = api_send_events(chat_id, query)
    end
    
    Rails.logger.debug responce.inspect
    Rails.logger.debug responce.body.inspect

  end
  
  #チャット受信
  def query_getchat(chat_id)
    Rails.logger.debug 'Brightpattern-query_getchat'
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
    Rails.logger.debug 'Brightpattern-api_get_events'
    Rails.logger.debug chat_id
    
    body = nil
    return send_api("/" + chat_id + "/events", body, false)
  end
  
  def create_json_to_send(text, html, expression)
    Rails.logger.debug("Brightpattern-create_json_to_send")

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
  
  def send_unsolicited_response(sessionId, query)
    Rails.logger.debug("Brightpattern-send_unsolicited_response")
#        puts "Sending unsolicited response..."
#       conversation = Conversation.first
    headers = {
        "Content-Type": "application/json",
    }
    
    jwt_secret = "24db2224-9afc-4b8x-yeex-e1fe567c7564"
#    CUSTOMER_JWT_SECRET = Rails.application.secrets.customer_jwt_secret
    hostname = "https://dal-admin.faceme.com"

    sessionIdJwt = JWT.encode ({sessionId: sessionId}), jwt_secret, 'HS256'

    body = {
        answer: query,
        answerAvatar: JSON.generate({}),
        sessionIdJwt: sessionIdJwt
    }

    options = {
        body: JSON.generate(body),
        headers: headers,
    }

    response = HTTParty.post("#{hostname}/api/v1/avatar/#{conversation.avatar_session_id}/speak", 
        body: JSON.generate(body),
        headers: headers
    )
    Rails.logger.debug("&&&RESPONSE&&&")
    Rails.logger.debug response
  end
  
end
