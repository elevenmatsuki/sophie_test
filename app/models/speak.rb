class Speak < ApplicationRecord
    attr_accessor :params

    DEFAULT_HOSTNAME = Rails.application.secrets.default_hostname
    CUSTOMER_JWT_SECRET = Rails.application.secrets.customer_jwt_secret

    def initialize(params)
        @params = params
    end

    def send_unsolicited_response
        puts "Sending unsolicited response..."
        conversation = Conversation.first
        headers = {
            "Content-Type": "application/json",
        }
        hostname = 'https://dal-admin.faceme.com';

        sessionIdJwt = JWT.encode ({sessionId: conversation.avatar_session_id}), CUSTOMER_JWT_SECRET, 'HS256'

        body = {
            answer: params["text_to_speak"],
            answerAvatar: JSON.generate({}),
            sessionIdJwt: sessionIdJwt
        }

        options = {
            body: JSON.generate(body),
            headers: headers,
        }

        Rails.logger.debug "AvatarsessionId : " + conversation.avatar_session_id
        Rails.logger.debug "sessionIdJwt : " + sessionIdJwt

        response = HTTParty.post("#{hostname}/api/v1/avatar/#{conversation.avatar_session_id}/speak", 
            body: JSON.generate(body),
            headers: headers
        )
    end
end