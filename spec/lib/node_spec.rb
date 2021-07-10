# frozen_string_literal: true

describe BehaviorTree.const_get(:Node) do
  subject { described_class.new }
  it { expect(subject).to respond_to :tick! }
  it { expect(subject).to respond_to :halt! }

  describe '.status=' do
    let(:other_node) { BehaviorTree.const_get(:Node).new }
    before { other_node.status.failure! }
    it { expect(subject).to be_success }
    it { expect(other_node).to be_failure }

    it 'copies the status without affecting the one passed as argument' do
      subject.status = other_node.status

      expect(subject).to be_failure
      expect(other_node).to be_failure

      subject.status.running!

      expect(subject).to be_running
      expect(other_node).to be_failure
    end
  end
end
