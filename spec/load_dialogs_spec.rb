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
                        {"what"=>"the whats4", "dialog"=> ["test 23", "response 23", "test 24", "response 24"]},
                        {"what"=>"the whats5", "dialog"=> ["test 25", "response 25"]}
                      ]
                    }

      allow(YAML).to receive(:load_file).with('spec/fixtures/test.yaml').and_return(test_dialog)
      allow(YAML).to receive(:load_file).with('spec/fixtures/pizza.yaml').and_return(test_dialog2)
      @mock_aws = double('aws mock')
      allow(@mock_aws).to receive(:post_message).and_return({'message': 'response 1'})
      allow_any_instance_of(Dialog).to receive(:create_example_group).and_return(::RSpec.describe('test'))

    }

    describe :load_dialog do
      it 'creates a dialog' do
        dialog = Dialog.new(describe:  'test description', name: 'my dialog', interactions: dialog_hash)

        expect(dialog.describe).to eql('test description')
        expect(dialog.interactions().length).to eql(2)
      end
    end


    describe :single_file do
      subject(:dialogs) {LoadDialogs.run_dialogs('botspec_spec', 'spec/fixtures/test.yaml') }

      it 'loads a single file and breaks down dialogs' do
        expect(dialogs.length).to eql(2)
      end

      it 'first dialog has 2 interactions' do
        dialog = dialogs[0]

        expect(dialog.interactions.length).to eql(4)
      end

      it 'second dialog has 1 interactions' do
        dialog = dialogs[1]

        expect(dialog.interactions.length).to eql(2)
        expect(dialog.name).to eql 'the whats2'
      end
    end

    describe :directory_files do

      subject(:dialogs) {LoadDialogs.run_dialogs('botspec_spec', 'spec/fixtures/**') }

      it 'loads 2 files and breaks down into 5 dialogs' do
        expect(dialogs.length).to eql(5)
      end

      it 'third dialog has 2  interactions' do
        dialog = dialogs[2]

        expect(dialog.interactions.length).to eql(4)
        expect(dialog.name).to eql 'the whats3'
      end
    end
      
  end
end
