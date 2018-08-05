require 'yaml'

class LoadDialogs

#  def initialize(dialog_file)
#    @specs= YAML.load_file(dialog_file)
#  end

  def self.load_dialogs dialog_file

    dialogs = YAML.load_file(dialog_file)
    return dialogs['dialogs'].collect{ |dialog|
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
