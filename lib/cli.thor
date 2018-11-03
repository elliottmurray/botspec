
require 'botspec/lex/lex_service.rb'
require 'botspec/version'
require 'thor'
require 'load_dialogs.rb'

class CLI < Thor

  desc 'verify', "Verify a chat suite"
  method_option :dialogs, aliases: "-f", desc: "Yaml file containing dialogs", :required => true
  def verify()
    puts options[:dialogs]
    puts "!!!!!"
    dialogs = options[:dialogs]
    LoadDialogs.run_dialogs('test', dialogs)
  end

end
