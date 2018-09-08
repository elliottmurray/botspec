require 'aws-sdk'

module BotSpec
  module AWS
    class LexService
      def self.load(config)
        return LexService.new(config)
      end

      def initialize(config)
        @config = config
        lex_region = config[:region] || 'us-east-1:w'
        #
        #@credentials = AWS::CognitoIdentityCredentials.new({
        #  IdentityPoolId: "#{lexRegion}:#{poolId}"
        #});

        @lex_client = Aws::Lex.new(
           region: ENV["LEX_FAQ_AWS_REGION"],
           access_key_id: ENV["LEX_FAQ_AWS_ACCESS_ID"],
           secret_access_key: ENV["LEX_FAQ_AWS_SECRET_ACCESS_KEY"])

      #  @lex = AWS::Lex.new({
      #  })



      end
      def post_message message, user_id

      resp = @lex_client.post_text({
        bot_name: Lex::Bot::NAME,
        bot_alias: Lex::Bot::VERSION,
        user_id: user_id,
        session_attributes: {},
        input_text: message
      })

    sleep(1);
      end
    end
  end
end

