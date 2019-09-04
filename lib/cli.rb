
require 'botspec/lex/lex_service.rb'
require 'botspec/version'
require 'thor'
require 'load_dialogs.rb'
require 'rspec/botspec_runner.rb'

module Botspec
  class CLI < Thor

    desc 'verify', "Verify a chat suite"
    method_option :dialogs, aliases: "-f", desc: "Path to yaml dialogs", :required => true
    method_option :botname, aliases: "-n", desc: "The name of the Amazon Web Services Lex chatbot"
    def verify()
      dialogs = options[:dialogs]

      if options[:botname]
        bot_name = options[:botname]
      elsif raise "No bot specified"
      end

      puts "running specs in #{dialogs} for bot #{bot_name}"

      BotSpec::BotSpecRunner.run({dialogs_path: dialogs, botname: bot_name})
    end

  end
end
