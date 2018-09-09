require 'aws-sdk'

module BotSpec
  module AWS
    class LexService
      def self.load(config)
        return LexService.new(config)
      end

      def initialize(config)
        @config = config
        @user_id = "pizza-chat-#{SecureRandom.uuid}"
        
        #
        #@credentials = AWS::CognitoIdentityCredentials.new({
        #  IdentityPoolId: "#{lexRegion}:#{poolId}"
        #});

        @lex_client ||= Aws::Lex::Client.new
         
      end

      def interaction_to_lex_message(message)
        return {
          bot_name: "PizzaOrderingBot", # required
          bot_alias: "$LATEST", # required
          user_id: @user_id, # required
          session_attributes: {
            "String" => "String",
          },
          request_attributes: {
            "String" => "String",
          },
          input_text: message, # required
        }
      end

      def post_message message, user_id
        puts message
        resp = @lex_client.post_text(interaction_to_lex_message(message))
        puts resp
        sleep(1);
      end
    end
  end
end

