require 'spec_helper.rb'
require 'load_dialogs.rb'

RSpec.describe 'load yaml file' do
  let(:dialog_hash) { {'what': 'name', 'dialog': ['test utterance', 'second utterance'] } }

  describe :load_dialogs do

    before(:each) {
      test_dialog = {"description"=>"Hospital miss-selection tests", 
                      "dialogs"=>[
                        {"what"=>"the whats1", "dialog"=> ["test 1", "response 1", "test 2", "response 2"]},
                        {"what"=>"the whats2", "dialog"=> ["test 3", "response 3"]}
                      ]
                    }
      allow(YAML).to receive(:load_file).and_return(test_dialog)

      @mock_aws = double('aws mock')
      allow(@mock_aws).to receive(:post_message).and_return({'message': 'response 1'})
      allow_any_instance_of(Dialog).to receive(:run_dialog)

      @dialogs = LoadDialogs.run_dialogs('./spec/test.yaml')
    }

    it 'loads a single file and breaks down dialogs' do
      
      expect(@dialogs.length).to eql(2)
    end

    it 'first dialog has 2 interactions' do
      dialog = @dialogs[0]

      expect(dialog.interactions.length).to eql(4)
    end

    it 'second dialog has 1 interactionss' do
      dialogs = @dialogs[1]

      expect(dialogs.interactions.length).to eql(2)
      expect(dialogs.name).to eql 'the whats2'
    end
  end

  it 'creates a dialog' do
    dialog = Dialog.new(dialog_hash)

    expect(dialog.interactions().length).to eql(2)
  end
end
