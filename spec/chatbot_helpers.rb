
require 'botspec/lex/lex_service.rb'


module ChatbotHelpers
  
  @client = nil

  # this should be hidden nicely in a context method
  def init_chatbot_client
    @client = BotSpec::AWS::LexService.new({botname: 'WebUiOrderFlowers'})
  end
  
  def user(utterance)
    puts "\n\nUser utters: " + utterance.inspect
    @response = @client.post_message(utterance, 'user_id')
  end
  
  def chatbot(expected_response)
    puts "\nExpected response: " + expected_response.inspect
    puts   "Actual response:   " + @response.message.inspect
    expect(@response.message).to match(expected_response)
  end
  
end

