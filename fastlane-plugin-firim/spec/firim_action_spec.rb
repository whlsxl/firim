describe Fastlane::Actions::FirimAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The firim plugin is working!")

      Fastlane::Actions::FirimAction.run(nil)
    end
  end
end
