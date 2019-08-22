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

      subject(:dialogs) {LoadDialogs.run_dialogs('botspec_spec', 'spec/fixtures/**') }

      it 'loads 2 files and breaks down into 5 dialogs' do
        expect(dialogs.length).to eql(5)
      end

      it 'third dialog has 2 interactions' do
        dialog = dialogs[2]
        expect(dialog.interactions.length).to eql(4)
        expect(dialog.name).to eql 'the whats3'
      end
    end
      
  end

  describe :create_example do

    it 'creates something (should be an example)' do
      dialog = Dialog.new({:describe => 'desc', :name => 'nome'})
      lex_stub = instance_double('BotSpec::AWS::LexService')

      allow(dialog).to receive(:lex_chat).and_return(lex_stub)

      interactions = ['request something', 'response SOMEWEIRD STUFF THAT WILL STILL MATCH THE REGEXBBBBBBBBB here']
      assertions = dialog.create_example(interactions)
      expect(assertions.size).to eql 1
      expect(assertions[0]).to eql(RSpec::ExampleGroups::DescNome)
    end

    it 'fails with regular mismatch text' do
      dialog = Dialog.new({:describe => 'desc', :name => 'mismatch'})
      stubbed_post_text_response = Aws::Lex::Client.new(stub_responses: true).stub_data(:post_text)
      stubbed_post_text_response.message = "mock response here"

      lex_service_with_stubbed_aws_client = BotSpec::AWS::LexService.new({
                                                                           stub_responses: {
                                                                            operation_to_stub: :post_text, 
                                                                            stub_data: stubbed_post_text_response
                                                                          },
                                                                          botname: 'TESTCHATBOT'})

      allow(dialog).to receive(:lex_chat).and_return(lex_service_with_stubbed_aws_client)

      interactions = ['initiating comment from user', 'non matching text here']

      assertions = []

      RSpec::Core::Sandbox.sandboxed do |config|
        assertions = dialog.create_example(interactions)
        expect(assertions.size).to eql 1
        result_of_run = assertions[0].run()
        puts "\n\n result of RUN: " + result_of_run.inspect
      end

      expect(assertions[0].examples.first.execution_result.status).to eq(:failed)
      expect(assertions[0].examples.first.execution_result.exception).to be_a(RSpec::Expectations::ExpectationNotMetError)
      expect(assertions[0].examples.first.execution_result.exception.message).to eq('expected "mock response here" to match "non matching text here"')

      api_requests = lex_service_with_stubbed_aws_client.lex_client.api_requests
      expect(api_requests.size).to eq(1)
      expect(api_requests[0][:operation_name]).to eq(:post_text)
      expect(api_requests[0][:params][:input_text]).to eq("initiating comment from user")
    end

    it 'succeeds with wildcard exact text' do
      dialog = Dialog.new({:describe => 'desc', :name => 'wildcard'})
      stubbed_post_text_response = Aws::Lex::Client.new(stub_responses: true).stub_data(:post_text)
      stubbed_post_text_response.message = "response SOMEWEIRD STUFF THAT WILL STILL MATCH THE REGEXBBBBBBBBB here"

      lex_service_with_stubbed_aws_client = BotSpec::AWS::LexService.new({
                                                                           stub_responses: {
                                                                            operation_to_stub: :post_text, 
                                                                            stub_data: stubbed_post_text_response
                                                                          },
                                                                          botname: 'TESTCHATBOT'})

      allow(dialog).to receive(:lex_chat).and_return(lex_service_with_stubbed_aws_client)

      interactions = ['request wildcard something', 'response .* here']
      assertions = dialog.create_example(interactions)

      expect(assertions.size).to eql 1
      expect(assertions[0]).to eql(RSpec::ExampleGroups::DescWildcard)
      assertions[0].run()

      expect(assertions[0].examples.first.execution_result.status).to eq(:passed)
      api_requests = lex_service_with_stubbed_aws_client.lex_client.api_requests

      expect(api_requests.size).to eq(1)
      expect(api_requests[0][:operation_name]).to eq(:post_text)
      expect(api_requests[0][:params][:input_text]).to eq("request wildcard something")

    end

  end
end
