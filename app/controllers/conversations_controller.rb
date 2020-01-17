class ConversationsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  
  orchestration = nil

  def index
    logger.debug("ConversationsController-index")
    logger.debug(params)

    # Create a single-use token - this is what causes the digital human to display in the first place
    Conversation.new.authenticate_to_faceme(params)

    # Grabs the exisitng single-use token from the database (which we just created) and a necessary api key from YAML and supplies them to the front-end
    # There are other ways to do this - you could use AJAX directly from the front-end and return some values stored in a database somewhere, or grab a file
    # from an online bucket like S3 which contains the parameters - single use has to be instantiated every time, which makes my method more palatable for Rails
    
    @token = Conversation.first.token
    @api_key = Rails.application.secrets.fm_api_key

  end
  
  def create
    # Change the second parameter to another NLP provider in order to query against that provider
    # You could also implement a custom cascading check against multiple NLP providers.

    logger.debug("ConversationsController-create")
    logger.debug params.inspect
    
    # Houdify
#    orchestration = Orchestration.new(params, "Houndify")
#    response = orchestration.orchestrate
#    render json: response

    # BrightPattern
    orchestration = Orchestration.new(params, "BrightPattern")
    orchestration.orchestrate
    
    response = orchestration.request_chat

    render json: response

#    bp_chat_id = ""

#    if session[:bp_chat_id].blank?
#      response = orchestration.request_chat

#      response_body = JSON.parse(response.body)
#      bp_chat_id = response_body["chat_id"]
#     session[:bp_chat_id] = bp_chat_id
#    else
#      bp_chat_id = session[:bp_chat_id]
#    end

#    logger.debug("SESSION-Chat_id")
#    logger.debug bp_chat_id

#    if !params["fm-question"].blank?
#      response = orchestration.send_chat(bp_chat_id)
#      Rails.logger.debug("SENDCHAT-response")
#      Rails.logger.debug response.inspect

#      render json: response
#    else
#      logger.debug("ConversationsController-GETEVENT")
      
#      response  = {}
#      if orchestration
#        response = orchestration.get_chat(bp_chat_id)
#        response.each do |var|
#          logger.debug(var)
#        end
#      end
      
#      Rails.logger.debug("ConversationsController-response")
#      Rails.logger.debug response.inspect
      
#      render json: response
#    end
  end
  
  def check
    logger.debug("ConversationsController-check")
    
    if orchestration then
    end
  end
end
