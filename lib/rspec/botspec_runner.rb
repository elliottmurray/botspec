require 'rspec'
require 'load_dialogs.rb'

module BotSpec
    class BotSpecRunner < RSpec::Core::Runner

      def configure_rspec
        config = ::RSpec.configuration

      end

      def run(out, err)
        setup(err, out)
        return @configuration.reporter.exit_early(@configuration.failure_exit_code) if RSpec.world.wants_to_quit
        puts "In run here"

        run_specs(LoadDialogs.run_dialogs('lex/regression_tests/dialogs/intents/claim_enquire.yaml')).tap do
          puts 'hello'
          persist_example_statuses
        end

     #   run_specs(@world.ordered_example_groups).tap do
     #     persist_example_statuses
     #   end

      end
    end
end

