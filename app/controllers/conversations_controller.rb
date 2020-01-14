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
    
    logger.debug("$$$ SESSION $$$")
    if !session[:bp_session].blank?
      logger.debug(session[:bp_session])
    end
    logger.debug("$$$ SESSION $$$")


    # Houdify
#    orchestration = Orchestration.new(params, "Houndify")
#    response = orchestration.orchestrate
#    render json: response

    # BrightPattern
    if !params["fm-question"].blank?
      orchestration = Orchestration.new(params, "BrightPattern")

      response = orchestration.orchestrate

      Rails.logger.debug("REQUEST-response")
      Rails.logger.debug response.inspect

      response = orchestration.send_chat

      Rails.logger.debug("SENDCHAT-response")
      Rails.logger.debug response.inspect

      logger.debug("ConversationsController-sleepB")
      sleep(1)
      logger.debug("ConversationsController-sleepA")

      response = orchestration.get_chat

      response.each do |var|
        logger.debug(var)
      end

      Rails.logger.debug("GETCHAT-response")
      Rails.logger.debug response.inspect
      session[:bp_session] = "123456"

      render json: response
    else
      logger.debug("ConversationsController-GETEVENT")
      
      response  = {}
      
      if orchestration
        response = orchestration.get_chat
        response.each do |var|
          logger.debug(var)
        end
      end
      
      Rails.logger.debug("ConversationsController-response")
      Rails.logger.debug response.inspect
      
      render json: response
    end
  end
  
  def check
    logger.debug("ConversationsController-check")
    
    if orchestration then
    end
  end
end
