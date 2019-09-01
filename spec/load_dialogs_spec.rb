require 'rspec/core/sandbox'
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

      allow(YAML).to receive(:load_file).with('spec/fixtures/pizza.yaml').and_return(test_dialog)
      allow(YAML).to receive(:load_file).with('spec/fixtures/test.yaml').and_return(test_dialog2)
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
      subject(:dialogs) {LoadDialogs.run_dialogs('botspec_spec', 'spec/fixtures/pizza.yaml') }

      it 'loads a single file and breaks down dialogs' do
        expect(dialogs.length).to eql(2)
      end

      it 'first dialog has 2 interactions' do
        dialog = dialogs[0]
        expect(dialog.file).to eql('spec/fixtures/pizza.yaml')
        expect(dialog.interactions.length).to eql(4)
        expect(dialog.name).to eql 'the whats1'
      end

      it 'second dialog has 1 interactions' do
        dialog = dialogs[1]

        expect(dialog.interactions.length).to eql(2)
        expect(dialog.name).to eql 'the whats2'
      end
    end

    describe :directory_files do

      #subject(:dialogs) {LoadDialogs.run_dialogs('botspec_spec', 'spec/fixtures/**') }


      it 'loads 2 files and breaks down into 5 dialogs' do
        dialogs = LoadDialogs.run_dialogs('botspec_spec', 'spec/fixtures/**')

        expect(dialogs.length).to eql(5)
      end

      it 'third dialog has 2 interactions' do
        dialogs = LoadDialogs.run_dialogs('botspec_spec', 'spec/fixtures/**')

        dialog = dialogs[2]

        expect(dialog.name).to eql 'the whats3'
        expect(dialog.interactions.length).to eql(4)
      end
    end

  end

  describe :create_example do
     let(:lex_stub) { instance_double('BotSpec::AWS::LexService')}

     before(:each) do 
      RSpec.clear_examples
    end

    it 'creates one example' do
      interactions = ['request something', 'response here']
      dialog = Dialog.new({:describe => 'desc', :name => 'nome', :interactions => interactions})
      allow(dialog).to receive(:lex_chat).and_return(lex_stub)

      assertions = dialog.create_example
      expect(assertions).to eql(RSpec::ExampleGroups::DescNome)
    end

    it 'creates one example with 2 expects' do
      interactions = ['request something', 'response here', 'next request', 'later response']
      dialog = Dialog.new({:describe => 'desc', :name => 'nome', :interactions => interactions})
      allow(dialog).to receive(:lex_chat).and_return(lex_stub)

      assertions = dialog.create_example
      expect(assertions).to eql(RSpec::ExampleGroups::DescNome)
    end

    it 'passes when the response from the stubbed chatbot matches our expected response' do
      interactions = ['a comment expecting a nice stubbed response back', 'a nice stub response from the']
      dialog = Dialog.new({:describe => 'desc', :name => 'matching', :interactions => interactions})

      allow(dialog).to receive(:lex_chat).and_return(lex_stub)

      resp = {:message => 'a nice stub response from the chatbot'}
      expect(lex_stub).to receive(:post_message).with('a comment expecting a nice stubbed response back').and_return(resp)

      allow(dialog).to receive(:lex_chat).and_return(lex_stub)

      assertions = []

      RSpec::Core::Sandbox.sandboxed do |config|
        assertions = dialog.create_example()
        expect(assertions).to eql(RSpec::ExampleGroups::DescMatching)
        assertions.run()
      end
      expect(assertions.examples.first.execution_result.status).to eq(:passed)
      expect(assertions.examples.first.execution_result.exception).to eq(nil)
    end

    it 'fails with regular mismatch text' do
      interactions = ['initiating comment from user', 'non matching text here']
      dialog = Dialog.new({:describe => 'desc', :name => 'mismatch', :interactions => interactions})
      stubbed_post_text_response = Aws::Lex::Client.new(stub_responses: true).stub_data(:post_text)
      stubbed_post_text_response.message = "mock response here"

      allow(dialog).to receive(:lex_chat).and_return(lex_stub)

      resp = {:message => 'mock response here'}
      expect(lex_stub).to receive(:post_message).with('initiating comment from user').and_return(resp)

      allow(dialog).to receive(:lex_chat).and_return(lex_stub)

      assertions = nil 

#      RSpec::Core::Sandbox.sandboxed do |config|
        assertions = dialog.create_example
        expect(assertions).to eql(RSpec::ExampleGroups::DescMismatch)
        assertions.run()
 #     end

      expect(assertions.examples.first.execution_result.status).to eq(:failed)
      expect(assertions.examples.first.execution_result.exception).to be_a(RSpec::Expectations::ExpectationNotMetError)
      expect(assertions.examples.first.execution_result.exception.message).to eq('expected "mock response here" to match "non matching text here"')
    end

    it 'succeeds with wildcard exact text' do
      interactions = ['request wildcard something', 'response .* here']
      dialog = Dialog.new({:describe => 'desc', :name => 'wildcard', :interactions => interactions})

      allow(dialog).to receive(:lex_chat).and_return(lex_stub)
      resp = {:message => "response THIS WILL STILL MATCH THE REGEX here"}
      expect(lex_stub).to receive(:post_message).with('request wildcard something').and_return(resp)

      assertions = dialog.create_example

      expect(assertions).to eql(RSpec::ExampleGroups::DescWildcard)
      assertions.run()

      expect(assertions.examples.first.execution_result.status).to eq(:passed)
    end

  end
end
