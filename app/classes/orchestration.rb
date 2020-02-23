class Orchestration
    attr_accessor :query, :conversation_state, :location, :partner, :response

    def initialize(params, partner)
      Rails.logger.debug 'Orchestration-initialize'
      Rails.logger.debug params

      @query = params["fm-question"] # string, query from the STT engine of UneeQ
      @conversation_state = params["fm-conversation"].blank? ? nil : params["fm-conversation"] # Maintain conversation state between utterances
      @location = params["fm-custom-data"].blank? ? {} : JSON.parse(params["fm-custom-data"])
      @partner = partner # string, the name of the partner company we reach out to
      @response = nil
      @bp = nil
      
      @query = "おはようございます"
      fm_avater = params["fm-avatar"].blank? ? {} : JSON.parse(params["fm-avatar"])
      @avatar_session_id = fm_avater ? fm_avater["avatarSessionId"] : ""

      Rails.logger.debug @avatar_session_id
    end

    def orchestrate
      Rails.logger.debug 'Orchestration-orchestrate'
      case @partner
      when "Houndify"
          Houndify.new.query_houndify(@location, @conversation_state, @query)
      when "BrightPattern"
        @bp = Brightpattern.new
        @bp.send_unsolicited_response(@avatar_session_id,@query)
      else
          return nil
      end
    end
    
    def request_chat
      Rails.logger.debug 'Orchestration-request_chat'
      if @bp then 
        return @bp.api_request_chat
      end
      
    end
    
    def send_chat(chat_id)
      Rails.logger.debug 'Orchestration-send_chat'
      if @bp then 
        return @bp.query_sendchat(chat_id, @query)
      end
    end
    
    def get_chat(chat_id)
      Rails.logger.debug 'Orchestration-get_chat'
      if @bp then 
        return @bp.query_getchat(chat_id)
      end      
    end
end
