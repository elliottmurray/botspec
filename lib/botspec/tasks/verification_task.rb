require 'load_dialogs.rb'
require 'rspec/botspec_runner.rb'

require 'rspec'
require 'rspec/core/formatters/json_formatter'

module Botspec
  class VerificationTask < ::Rake::TaskLib

    attr_reader :name

    def initialize(name)
      @name = name
      yield self
      rake_task
    end

    def rake_task
      namespace :botspec do

        desc "Verify botspecs #{name}"
        task "verify:#{name}" do |t, args|
          BotSpec::BotSpecRunner.run({})
#          config = RSpec.configuration
#          json_formatter = RSpec::Core::Formatters::JsonFormatter.new(config.output_stream)
#
#          # create reporter with json formatter
#          reporter =  RSpec::Core::Reporter.new(json_formatter)
#          # set reporter for rspec configuration
#          config.instance_variable_set(:@reporter, reporter)
#
          # execute rspec runner
          # 'example_spec.rb' is the location of the spec file

          # output test result as json
          # see example output in `rspec_json_formatter_result.rb`
#          puts json_formatter.output_hash

#          RSpec.configure do |config|
#            # Enable flags like --only-failures and --next-failure
#            config.example_status_persistence_file_path = ".rspec_status"
#            config.expose_dsl_globally = true
#
#            # Disable RSpec exposing methods globally on `Module` and `main`
#            config.disable_monkey_patching!
#
#            config.expect_with :rspec do |c|
#              c.syntax = :expect
#            end
#          end
#          BotSpec::RSpec::BotSpecRunner.new().run
#
        end
      end
    end
  end

end
