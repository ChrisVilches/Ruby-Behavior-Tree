# frozen_string_literal: true

describe BehaviorTree.const_get(:Node) do
  subject { described_class.new }
  it { is_expected.to respond_to :tick! }
  it { is_expected.to respond_to :halt! }

  describe '.status=' do
    let(:other_node) { BehaviorTree.const_get(:Node).new }
    before { other_node.status.failure! }
    it { is_expected.to be_success }
    it { expect(other_node).to be_failure }

    it 'copies the status without affecting the one passed as argument' do
      subject.status = other_node.status

      is_expected.to be_failure
      expect(other_node).to be_failure

      subject.status.running!

      is_expected.to be_running
      expect(other_node).to be_failure
    end
  end
end
