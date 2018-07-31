require 'yaml'

module BotSpec
  module Load
    def self.load(dialog_file)
      return LoadDialogs.new(dialog_file)
    end
  end
end

class LoadDialogs

  def initialize(dialog_file)
    @specs= YAML.load_file(dialog_file)
  end

  def dialogs
    return @specs['dialogs'].collect{ |dialog|
      Dialog.new(dialog)
    }
  end
end

class Dialog
  attr_reader :what, :steps

  def initialize(dialog)
    @what = dialog['what']
    @interactions = dialog['dialog']
  end

  def name
    @what
  end

  def interactions
    @interactions
  end
end
