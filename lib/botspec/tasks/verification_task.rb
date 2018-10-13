require 'load_dialogs.rb'

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
          puts 'test taskhere '

          LoadDialogs.run_dialogs('lex/regression_tests/dialogs/intents/claim_enquire.yaml')
        end
      end
    end
  end

end
