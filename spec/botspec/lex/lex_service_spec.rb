
require 'spec_helper.rb'

require 'botspec/lex/lex_service'

RSpec.describe 'aws lex service' do

  before(:each) {

    @mock_aws = double('aws mock')
    allow(@mock_aws).to receive(:post_text)
    allow_any_instance_of(BotSpec::AWS::LexService).to receive(:lex_client).and_return(@mock_aws)

    @service = BotSpec::AWS::LexService.load({region: 'us-east-1', botname: 'PizzaOrderingBot'})
  }

  it 'posts message' do
    allow(@service).to receive(:interaction_to_lex_message).with('pizza').and_return('hashed pizza')
    expect(@mock_aws).to receive(:post_text).with('hashed pizza')

    @service.post_message('pizza')
  end

  it 'interaction prepares message' do

    response = @service.interaction_to_lex_message('my message')

    expect(response).to include(bot_name: 'PizzaOrderingBot', input_text: 'my message')

  end
end
