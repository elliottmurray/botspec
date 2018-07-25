require 'yaml'

module BotSpec

  class LoadDialogs
    class << self
      def load(dialog_file)
        return BotSpec::LoadDialogs.new(dialog_file)
      end
    end

    def initialize(dialog_file)
      @interactions = YAML.load_file(dialog_file)
    end

    def interactions
      return @interactions['tests'].collect{ |interaction|
        BotSpec::Interaction.new(interaction)
      }
    end
  end

  class Interaction
    attr_reader :what, :steps

    def initialize(interaction)
      @what = interaction['what']
      @dialog = interaction['dialog']
    end

    def dialog
      return @dialog
    end
  end
end
