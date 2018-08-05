RSpec.describe Botspec do

  describe 'CLI' do
    let(:test_file) {'./spec/test.yaml'}
    let(:dialogs) { [Dialog.new({what: ['test utterance']})] }

    subject { BotSpec::CLI.new() }

    it 'loads dialogs and runs spec for each' do
      allow(LoadDialogs).to receive(:load_dialogs).with(test_file).and_return(dialogs)
      expect(subject).to receive(:run_spec).with(dialogs[0])

      subject.verify(test_file)
    end

    it 'runs spec for each dialog'
  end
end
