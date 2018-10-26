require 'yaml'
require 'hashie'
require 'botspec/lex/lex_service.rb'
require 'rspec'

require "bundler/setup"

class LoadDialogs

  def self.run_dialogs dialog_file
    puts dialog_file
    dialogs = YAML.load_file(dialog_file)
    dialogs = Hashie.symbolize_keys dialogs
    #dialogs = dialogs.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    dialogs[:dialogs].collect{ |dialog|
      Dialog.new("${dialogs[:description]}  ${dialogs[:what]}", dialog)
    }.each{ |dialog|
      dialog.create_example_group
    }
  end
end

class Dialog
  attr_reader :what, :steps, :describe

  def initialize(description, dialog)
    @describe = description
    @what = dialog[:what]
    @interactions = dialog[:dialog]
  end

  def name
    @what
  end

  def interactions
    @interactions
  end


  def lex_chat
    @lex_chat ||= BotSpec::AWS::LexService.new({})
  end

  def create_example_group()
    @examples = create_example(@interactions).flatten
  end

  def examples
    @examples
  end

  def create_example(interactions, examples=[])
    return if interactions.size == 0

    @@lex_chat = lex_chat()
    spec = ::RSpec.describe @describe do

      it interactions[0] do
        resp = @@lex_chat.post_message(interactions[0], 'user_id')

        expect(resp[:message]).to eql(interactions[1])
      end
    end

    examples << spec
    create_example(interactions.drop(2), examples)

    examples
  end
end
