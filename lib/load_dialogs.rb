require 'yaml'
require 'hashie'
require 'botspec/lex/lex_service.rb'
require 'rspec'

require "bundler/setup"

class LoadDialogs

  def self.run_dialogs botname, dialogs_path
    @@botname = botname

    dialog_paths = Dir.glob(dialogs_path).sort.select{ |e| File.file? e }
    dialog_yamls = dialog_paths.collect{ |dialog_file| Hashie.symbolize_keys YAML.load_file(dialog_file).merge!(file: dialog_file) }

    dialog_yamls.collect{ |dialog_content|
      dialog_content[:dialogs].collect{ |dialog|
        Dialog.new({describe: dialog_content[:description], name: dialog[:what], interactions:  dialog[:dialog], file: dialog_content[:file]})
      }
    }.flatten
  end

  def self.botname
    @@botname
  end
end

class Dialog
  attr_reader :describe, :name, :interactions
  attr_accessor :file

  def initialize args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def interactions
    @interactions
  end

  def lex_chat
    @lex_chat ||= BotSpec::AWS::LexService.new({botname: LoadDialogs.botname})
  end

  def create_example()
    return if @interactions.size == 0
    interactions = @interactions

    @@lex_chat = lex_chat()
    ::RSpec.describe "#{@describe} #{@name}" do

      it @name do
        while interactions.size > 1 do
          resp = @@lex_chat.post_message(interactions[0])
          expect(resp[:message]).to match(interactions[1])
          interactions = interactions.drop(2)          
        end

        resp = @@lex_chat.post_message(interactions[0]) if interactions.size == 1
      end
    end

  end
end
