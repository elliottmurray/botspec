require 'yaml'
require 'hashie'

class LoadDialogs

#  def initialize(dialog_file)
#    @specs= YAML.load_file(dialog_file)
#  end

  def self.load_dialogs dialog_file

    dialogs = YAML.load_file(dialog_file)
    dialogs = Hashie.symbolize_keys dialogs
    #dialogs = dialogs.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    return dialogs[:dialogs].collect{ |dialog|
      Dialog.new(dialog)
    }
  end
end

class Dialog
  attr_reader :what, :steps

  def initialize(dialog)
    @what = dialog[:what]
    @interactions = dialog[:dialog]
  end

  def name
    @what
  end

  def interactions
    @interactions
  end
end
