RSpec.describe Botspec do

  describe 'CLI' do
    let(:test_file) {'./spec/test.yaml'}
    let(:dialogs) { [Dialog.new({'what': 'name', 'dialog': ['test utterance', 'second utterance']}),
                    Dialog.new({'what': 'name2', 'dialog': ['second dialog']})] }

    subject { BotSpec::CLI.new() }

    it 'loads dialogs and runs each dialog spec' do
      allow(LoadDialogs).to receive(:load_dialogs).with(test_file).and_return(dialogs)

      expect(subject).to receive(:run_dialog).with(dialogs[0])
      expect(subject).to receive(:run_dialog).with(dialogs[1])

      subject.verify(test_file)
    end


    describe 'run dialog' do

      it 'runs each interaction for a dialog' do
        cli = BotSpec::CLI.new()
        lex = double('lex')
        allow(cli).to receive(:lex_chat).and_return(lex)
        expect(lex).to receive(:submit_interaction).with('test utterance')
        expect(lex).to receive(:submit_interaction).with('second utterance')

        cli.run_dialog(dialogs[0])

      end
    end

  end
end
