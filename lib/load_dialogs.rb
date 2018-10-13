require 'yaml'
require 'hashie'
require 'botspec/lex/lex_service.rb'
require 'rspec'

require "bundler/setup"

class LoadDialogs

  def self.run_dialogs dialog_file
    dialogs = YAML.load_file(dialog_file)
    dialogs = Hashie.symbolize_keys dialogs
    #dialogs = dialogs.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    dialogs[:dialogs].collect{ |dialog|
      Dialog.new(dialog)
    }.each{ |dialog|
      dialog.run_dialog
    }
  end
end

class Dialog
  attr_reader :what, :steps

  def initialize(dialog)
    @describe = dialog[:description]
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

  def run_dialog()
    submit_interaction @interactions      
  end

  def submit_interaction(interactions)
    return if interactions.size == 0

    resp = lex_chat().post_message(interactions[0], 'user_id')

    ::RSpec.describe @describe do

      it interactions[1] do
        expect(resp[:message]).to eql(interactions[1])
      end
    end

    submit_interaction(interactions.drop(2))
  end
end
