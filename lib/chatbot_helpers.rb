
require 'botspec/lex/lex_service.rb'


module ChatbotHelpers
  
  @client = nil
  @logger = nil

  # this should be hidden nicely in a context method
  def init_chatbot_client
    @client = BotSpec::AWS::LexService.new({botname: 'WebUiOrderFlowers'})
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::INFO
  end
  
  def user(utterance)
    @logger.info "User says: " + utterance.inspect
    @response = @client.post_message(utterance, 'user_id')
  end
  
  def chatbot(expected_response)
    @logger.info "Expected response: " + expected_response.inspect
    @logger.info "Actual response:   " + @response.message.inspect
    expect(@response.message).to match(expected_response)
  end

  def intent_fired(intent_details)
    expected_intent = intent_details.first
    @logger.info "\n\n got this intent.data: " + @response.data.inspect

    expected_intent.keys.each do |key|
      expect(@response.data[key]).to eq(expected_intent[key])
    end

  end
  
end

