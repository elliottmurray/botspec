require 'aws-sdk'

module BotSpec
  module AWS
    class LexService
      def self.load(config)
        return LexService.new(config)
      end

      def initialize(config)
        @config = config
        #todo remove this hardcoded default
        @bot_name = config[:botname] || 'PizzaOrderingBot'
        @user_id = "pizza-chat-#{SecureRandom.uuid}"
        
        #
        #@credentials = AWS::CognitoIdentityCredentials.new({
        #  IdentityPoolId: "#{lexRegion}:#{poolId}"
        #});

         
      end

      def lex_client
        @lex_client ||= Aws::Lex::Client.new
      end

      def interaction_to_lex_message(message)
        return {
          bot_name: @bot_name,
          bot_alias: "$LATEST",
          user_id: @user_id,
          session_attributes: {
            "String" => "String",
          },
          request_attributes: {
            "String" => "String",
          },
          input_text: message,
        }
      end

      def post_message message
        resp = lex_client.post_text(interaction_to_lex_message(message))
        sleep(1);
        resp
      end
    end
  end
end

