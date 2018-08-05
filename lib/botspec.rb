
require 'botspec/lex/lex_service.rb'
require 'botspec/version'
require 'thor'
require 'load_dialogs.rb'

module BotSpec

  class CLI < Thor

    desc 'verify', "Verify a chat suite"
    method_option :dialogs, aliases: "-f", desc: "Yaml file containing dialogs", :required => true

    def verify(dialogs)
      LoadDialogs.load_dialogs(dialogs).each{ |dialog|
        run_spec(dialog)
      }

    end

    def run_spec(dialog)

    end

  end
end
