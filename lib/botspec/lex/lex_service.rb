require 'aws-sdk'

module BotSpec
  module AWS
    class LexService
      def self.load(config)
        return LexService.new(config)
      end

      def initialize(config)
        @config = config
      end

    end
  end
end

