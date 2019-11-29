class Orchestration
    attr_accessor :query, :conversation_state, :location, :partner, :response

    def initialize(params, partner)
        @query = params["fm-question"] # string, query from the STT engine of UneeQ
        @conversation_state = params["fm-conversation"].blank? ? nil : params["fm-conversation"] # Maintain conversation state between utterances
        @location = params["fm-custom-data"].blank? ? {} : JSON.parse(params["fm-custom-data"])
        @partner = partner # string, the name of the partner company we reach out to
        @response = nil
        Rails.logger.debug 'Orchestration-initialize'
    end

    def orchestrate
        Rails.logger.debug 'Orchestration-orchestrate'
        case @partner
        when "Houndify"
            Houndify.new.query_houndify(@location, @conversation_state, @query)
        else 
            return nil
        end
    end
end
