# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require 'net/http'
require 'uri'
require 'json'

class Brightpattern
  @chat_id = nil
  
  def initialize
    Rails.logger.debug 'Brightpattern-initialize'
    
    responce = api_request_chat
    
    Rails.logger.debug responce.inspect
    Rails.logger.debug responce.body.inspect
    
    responce_body = JSON.parse(responce.body)
    @chat_id = responce_body["chat_id"]

  end
  
  def query_sendchat(query)
    Rails.logger.debug 'Brightpattern-query_sendchat'
    
    if @chat_id then
      responce = api_send_events(query)
    end
    
    Rails.logger.debug 'Brightpattern-query_sendchat1'
    Rails.logger.debug responce.inspect
    Rails.logger.debug responce.body.inspect
    Rails.logger.debug 'Brightpattern-query_sendchat2'

  end
  
  def query_getchat
    Rails.logger.debug 'Brightpattern-query_getchat'
    msg = ""
    
    responce = api_get_events

    Rails.logger.debug responce.body.inspect
    responce_body = JSON.parse(responce.body)
    
    for events in responce_body["events"] do
      if events["event"] == "chat_session_message" then
        Rails.logger.debug "Message=" + events["msg"]
        msg = events["msg"]   #とりあえず最後のメッセージ
      end
    end
    
    msg = "Welcome to CBA"
    responce = create_json_to_send(msg, "", {})

    return responce
  end
  
  def api_request_chat
    Rails.logger.debug 'Brightpattern-api_request_chat'

    uri = URI.parse("https://cbadev.brightpattern.com/clientweb/api/v1/chats?tenantUrl=https%3A%2F%2Fcbadev.brightpattern.com%2F")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "MOBILE-API-140-327-PLAIN appId=\"e7926a805d904b11a21dbe114beaf098\", clientId=\"WebChat\""
    request.body = JSON.dump({
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
    Rails.logger.debug request.inspect

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end    
    
    return response
    
  end
  
  def api_send_events(query)
    Rails.logger.debug 'Brightpattern-api_send_events'
    Rails.logger.debug @chat_id
    
#    uri = URI.parse("https://cbadev.brightpattern.com/clientweb/api/v1/chats/c22f472f-a234-45ca-a759-6fb007cb5fce/events?tenantUrl=https%3A%2F%2Fcbadev.brightpattern.com%2F")
    uri = URI.parse("https://cbadev.brightpattern.com/clientweb/api/v1/chats/" + @chat_id + "/events?tenantUrl=https%3A%2F%2Fcbadev.brightpattern.com%2F")
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "MOBILE-API-140-327-PLAIN appId=\"e7926a805d904b11a21dbe114beaf098\", clientId=\"WebChat\""
    request.body = JSON.dump({
      "events" => [
        {
          "event" => "chat_session_message",
          "msg" => query
        }
      ]
    })

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end    
    
  end
  
  def api_get_events
    Rails.logger.debug 'Brightpattern-api_get_events'
    Rails.logger.debug @chat_id

#    uri = URI.parse("https://cbadev.brightpattern.com/clientweb/api/v1/chats/c22f472f-a234-45ca-a759-6fb007cb5fce/events?tenantUrl=https%3A%2F%2Fcbadev.brightpattern.com%2F")
    uri = URI.parse("https://cbadev.brightpattern.com/clientweb/api/v1/chats/" + @chat_id + "/events?tenantUrl=https%3A%2F%2Fcbadev.brightpattern.com%2F")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "MOBILE-API-140-327-PLAIN appId=\"e7926a805d904b11a21dbe114beaf098\", clientId=\"WebChat\""

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    return response
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
  
end
