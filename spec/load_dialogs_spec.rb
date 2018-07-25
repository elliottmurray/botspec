require 'spec_helper.rb'
require 'load_dialogs.rb'

RSpec.describe 'load yaml file' do

  before(:each) {
    @dialogs = BotSpec::LoadDialogs.load('./spec/test.yaml')
  }

  it 'loads a single file and breaks down interactions' do
    expect(@dialogs.interactions.length).to eql(3)
  end

  it 'first interaction has 4 dialogs' do
    interaction = @dialogs.interactions[0]

    expect(interaction.dialog.length).to eql(4)
  end

end
