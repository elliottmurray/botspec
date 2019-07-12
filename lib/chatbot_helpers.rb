
require 'botspec/lex/lex_service.rb'


module ChatbotHelpers
  
  @client = nil
  @logger = nil
  @response = nil

  def chatbot_client
    @client ||= BotSpec::AWS::LexService.new({botname: 'WebUiOrderFlowers'}) 
  end

  def the_logger
    @logger = @logger ||= Logger.new(STDOUT)
    @logger.level = Logger::INFO
    @logger
  end
  
  def user(utterance)
    the_logger.info "User says: " + utterance.inspect
    @response = chatbot_client.post_message(utterance, 'user_id')
  end
  
  def chatbot(expected_response)
    the_logger.info "Expected response: " + expected_response.inspect
    the_logger.info "Actual response:   " + @response.message.inspect
    expect(@response.message).to match(expected_response)
  end

  def intent_fired(intent_details)
    expected_intent = intent_details.first
    the_logger.info "\n\n got this intent.data: " + @response.data.inspect

    expected_intent.keys.each do |key|
      expect(@response.data[key]).to eq(expected_intent[key])
    end

  end
  
end

