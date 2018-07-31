
require 'spec_helper.rb'

require 'botspec/lex/lex_service'

RSpec.describe 'aws lex service' do

  before(:each) {
    @service = BotSpec::AWS::LexService.load({region: 'us-east-1'})
  }

  it 'posts message' do
    expect(@service).to_not  be_nil
  end
end
