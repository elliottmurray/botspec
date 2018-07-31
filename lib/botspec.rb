
require 'botspec/lex/lex_service.rb'
require 'botspec/version'
require 'thor'

module BotSpec
  class CLI < Thor
    desc 'verify', "Verify a chat suite"
    method_option :dialogs, aliases: "-f", desc: "Yaml file containing dialogs", :required => true

    def verify

    end

  end
end
