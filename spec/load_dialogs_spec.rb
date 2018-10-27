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
      test_dialog2 = {"description"=>"Dentist selection tests",
                      "dialogs"=>[
                        {"what"=>"the whats3", "dialog"=> ["test 21", "response 21", "test 22", "response 22"]},
                        {"what"=>"the whats4", "dialog"=> ["test 23", "response 23"]}
                      ]
                    }

      allow(YAML).to receive(:load_file).with('./spec/test.yaml').and_return(test_dialog)
      allow(YAML).to receive(:load_file).with('./spec/pizza.yaml').and_return(test_dialog2)
      @mock_aws = double('aws mock')
      allow(@mock_aws).to receive(:post_message).and_return({'message': 'response 1'})
      allow_any_instance_of(Dialog).to receive(:create_example_group).and_return(::RSpec.describe('test'))

      @dialogs = LoadDialogs.run_dialogs('botspec_spec', './spec/*')
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
    dialog = Dialog.new('test description', dialog_hash)

    expect(dialog.describe).to eql('test description')
    expect(dialog.interactions().length).to eql(2)
  end
end
