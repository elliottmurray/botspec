require 'spec_helper.rb'
require 'load_dialogs.rb'

RSpec.describe 'load yaml file' do
  let(:dialog_hash) { {'what': 'name', 'dialog': ['test utterance', 'second utterance'] } }

  describe :load_dialogs do

    before(:each) {

      @mock_aws = double('aws mock')
      allow(@mock_aws).to receive(:post_message)
      allow_any_instance_of(Dialog).to receive(:lex_chat).and_return(@mock_aws)

      @dialogs = LoadDialogs.run_dialogs('./spec/test.yaml')
    }

    it 'loads a single file and breaks down dialogs' do
      expect(@dialogs.length).to eql(3)
    end

    it 'first dialog has 4 interactions' do
      dialog = @dialogs[0]

      expect(dialog.interactions.length).to eql(4)
    end

    it 'second dialog has 6 interactionss' do
      dialogs = @dialogs[1]

      expect(dialogs.interactions.length).to eql(6)
      expect(dialogs.name).to eql 'User means sales'
    end
  end

  it 'creates a dialog' do
    dialog = Dialog.new(dialog_hash)

    expect(dialog.interactions().length).to eql(2)
  end
end
