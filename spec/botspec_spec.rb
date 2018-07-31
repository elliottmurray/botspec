RSpec.describe Botspec do

  describe 'CLI' do

    it 'loads dialogs and runs spec for each' do
      BotSpec::CLI.new().verify('./spec/test.yaml')

    end

    it 'runs spec for each dialog'
  end
end
