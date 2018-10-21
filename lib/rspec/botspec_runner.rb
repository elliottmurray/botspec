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

        run_specs(LoadDialogs.run_dialogs('specs/simple_dialog.yaml').map{|dialog| dialog.examples}.flatten).tap do
          persist_example_statuses
        end
      end
    end
end

