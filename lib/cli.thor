
require 'botspec/lex/lex_service.rb'
require 'botspec/version'
require 'thor'
require 'load_dialogs.rb'
require 'rspec/botspec_runner.rb'

class CLI < Thor

  desc 'verify', "Verify a chat suite"
  method_option :dialogs, aliases: "-f", desc: "Yaml file containing dialogs", :required => true
  def verify()
    dialogs = options[:dialogs]

    name = 'ElliottOrderFlowers'
    puts "running specs in #{dialogs} for bot #{name}"

    BotSpec::BotSpecRunner.run({dialogs_path: dialogs, botname: name})
  end

end
