require 'yaml'

module BotSpec

  class LoadDialogs
    class << self
      def load(dialog_file)
        return BotSpec::LoadDialogs.new(dialog_file)
      end
    end

    def initialize(dialog_file)
      @specs= YAML.load_file(dialog_file)
    end

    def dialogs
      return @specs['dialogs'].collect{ |dialog|
        BotSpec::Dialog.new(dialog)
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
end
