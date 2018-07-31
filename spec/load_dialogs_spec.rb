require 'spec_helper.rb'
require 'load_dialogs.rb'

RSpec.describe 'load yaml file' do

  before(:each) {
    @specs = BotSpec::Load.load('./spec/test.yaml')
  }

  it 'loads a single file and breaks down dialogs' do
    expect(@specs.dialogs.length).to eql(3)
  end

  it 'first dialog has 4 interactions' do
    dialog = @specs.dialogs[0]

    expect(dialog.interactions.length).to eql(4)
  end

  it 'second dialog has 6 interactionss' do
    dialogs = @specs.dialogs[1]

    expect(dialogs.interactions.length).to eql(6)
    expect(dialogs.name).to eql 'User means sales'
  end

end
