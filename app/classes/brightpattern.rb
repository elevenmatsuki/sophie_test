# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require 'net/http'
require 'uri'
require 'json'

class Brightpattern
  def initialize
    Rails.logger.debug 'Brightpattern-initialize'
    
    responce = api_request_chat
    
    Rails.logger.debug responce.inspect
    Rails.logger.debug responce.body.inspect
    
  end
  
  def query_brightpattern(query)
    Rails.logger.debug 'Brightpattern-query_brightpattern'
    
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
  
end
