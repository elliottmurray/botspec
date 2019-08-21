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

    after(:each) do
      #@assertions[0].examples.each{ |example| @assertions[0].remove_example example}
    end

    it 'creates something (should be an example)' do
      dialog = Dialog.new({:describe => 'desc', :name => 'nome'})
      stubbed_post_text_response = Aws::Lex::Client.new(stub_responses: true).stub_data(:post_text)
      stubbed_post_text_response.message = "response here"
      puts "\n\n afta stubbed post text resp: " + stubbed_post_text_response.inspect

      lex_service_with_stubbed_aws_client = BotSpec::AWS::LexService.new({
                                                                           stub_responses: {
                                                                            operation_to_stub: :post_text, 
                                                                            stub_data: stubbed_post_text_response
                                                                          },
                                                                          botname: 'TESTCHATBOT'})

      allow(dialog).to receive(:lex_chat).and_return(lex_service_with_stubbed_aws_client)

      interactions = ['request something', 'response here']
      @assertions = dialog.create_example(interactions)

      expect(@assertions.size).to eql 1
      expect(@assertions[0]).to eql(RSpec::ExampleGroups::DescNome)
      @assertions[0].run()

      expect(@assertions[0].examples.first.execution_result.status).to eq(:passed)
      api_requests = lex_service_with_stubbed_aws_client.lex_client.api_requests

      api_requests.each do |api_request|
        puts "\n\n request operation: " + api_request[:operation_name].inspect
        puts "\n\n params: " + api_request[:params].inspect
      end
      expect(api_requests[0][:operation_name]).to eq(:post_text)
      expect(api_requests[0][:params][:input_text]).to eq("request something")

    end

    it 'fails with regular mismatch text' do
      dialog = Dialog.new({:describe => 'desc', :name => 'mismatch'})
      stubbed_post_text_response = Aws::Lex::Client.new(stub_responses: true).stub_data(:post_text)
      stubbed_post_text_response.message = "mock response here"
      puts "\n\n afta stubbed post text resp: " + stubbed_post_text_response.inspect

      lex_service_with_stubbed_aws_client = BotSpec::AWS::LexService.new({
                                                                           stub_responses: {
                                                                            operation_to_stub: :post_text, 
                                                                            stub_data: stubbed_post_text_response
                                                                          },
                                                                          botname: 'TESTCHATBOT'})

      allow(dialog).to receive(:lex_chat).and_return(lex_service_with_stubbed_aws_client)

      interactions = ['initiating comment from user', 'non matching text here']
      @assertions = dialog.create_example(interactions)

      expect(@assertions.size).to eql 1
      #expect(@assertions[0]).to eql(RSpec::ExampleGroups::DescMismatch)

      reporter = double(RSpec::Core::Reporter)

      allow(reporter).to receive(:stop) { |arg| 
        puts "\n\n argument to STOP: " + arg.inspect
      }

      allow(reporter).to receive(:start_dump) { |arg| 
        puts "\n\n argument to START DUMP!: " + arg.inspect
      }

      allow(reporter).to receive(:example_group_started) { |arg| 
        puts "\n\n argument to example group started: " + arg.inspect
      }

      allow(reporter).to receive(:example_started) { |arg| 
        puts "\n\n argument to example started: " + arg.inspect
      }

      allow(reporter).to receive(:example_group_finished) { |arg|
        puts "\n\n argument to example group finished: " + arg.inspect
        #byebug
      }

      allow(reporter).to receive(:example_finished) { |arg| 
        arg.execution_result.record_finished(:passed, Time.now)
        arg.execution_result.exception = nil
        #byebug
        puts "\n\n argument to example finished: " + arg.inspect
      }

      allow(reporter).to receive(:example_failed) { |arg| 
        arg.execution_result.record_finished(:passed, Time.now)
        arg.execution_result.exception = nil
        puts "\n\n argument to example failed: " + arg.inspect
      }

      allow(reporter).to receive(:failed_examples).and_return([])

      allow(reporter).to receive(:fail_fast_limit_met?).and_return(false)

      my_runner = RSpec::Core::Runner.new({})
 
      array_of_example_groups = [@assertions[0].examples.first.example_group]

      res = my_runner.run_specs(array_of_example_groups)

      puts "\n\n result from my runner: " + res.inspect
      puts "\n\n @assertions[0].examples.first.execution_result.status: " + @assertions[0].examples.first.execution_result.status.inspect

      expect(@assertions[0].examples.first.execution_result.status).to eq(:failed)
      api_requests = lex_service_with_stubbed_aws_client.lex_client.api_requests

      api_requests.each do |api_request|
        puts "\n\n request operation: " + api_request[:operation_name].inspect
        puts "\n\n params: " + api_request[:params].inspect
      end

      expect(api_requests[0][:operation_name]).to eq(:post_text)
      expect(api_requests[0][:params][:input_text]).to eq("initiating comment from user")
    end

    it 'succeeds with wildcard exact text' do
      dialog = Dialog.new({:describe => 'desc', :name => 'wildcard'})
      stubbed_post_text_response = Aws::Lex::Client.new(stub_responses: true).stub_data(:post_text)
      stubbed_post_text_response.message = "response SOMEWEIRD STUFF THAT WILL STILL MATCH THE REGEX here"
      puts "\n\n afta stubbed post text resp: " + stubbed_post_text_response.inspect

      lex_service_with_stubbed_aws_client = BotSpec::AWS::LexService.new({
                                                                           stub_responses: {
                                                                            operation_to_stub: :post_text, 
                                                                            stub_data: stubbed_post_text_response
                                                                          },
                                                                          botname: 'TESTCHATBOT'})

      allow(dialog).to receive(:lex_chat).and_return(lex_service_with_stubbed_aws_client)

      interactions = ['request something', 'response .* here']
      @assertions = dialog.create_example(interactions)

      expect(@assertions.size).to eql 1
      expect(@assertions[0]).to eql(RSpec::ExampleGroups::DescWildcard)
      @assertions[0].run()

      expect(@assertions[0].examples.first.execution_result.status).to eq(:passed)
      api_requests = lex_service_with_stubbed_aws_client.lex_client.api_requests

      api_requests.each do |api_request|
        puts "\n\n request operation: " + api_request[:operation_name].inspect
        puts "\n\n params: " + api_request[:params].inspect
      end
      expect(api_requests[0][:operation_name]).to eq(:post_text)
      expect(api_requests[0][:params][:input_text]).to eq("request something")

    end

  end
end
