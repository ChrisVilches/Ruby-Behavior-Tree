# frozen_string_literal: true

module CustomNodes
  class WrongShouldTick < BehaviorTree.const_get(:NodeBase)
    private

    def should_tick?
      0
    end
  end
end

describe BehaviorTree.const_get(:NodeBase) do
  subject { described_class.new }

  it { is_expected.to respond_to :tick! }
  it { is_expected.to respond_to :halt! }

  describe '.status=' do
    let(:other_node) { BehaviorTree.const_get(:NodeBase).new }

    before { other_node.status.failure! }

    it { is_expected.to be_success }
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

  describe '.[]' do
    before { subject[:arbitrary_variable] = :hello_world }

    it { expect(subject[:arbitrary_variable]).to eq :hello_world }
    it { expect(subject.arbitrary_storage).to eq({ arbitrary_variable: :hello_world }) }
  end

  describe '.on_status_change' do
    subject { BehaviorTree::Nop.new(2) }

    context 'when status is changed manually' do
      it 'changes prev status' do
        subject.status.running!
        subject.status.failure!
        is_expected.to be_failure
        expect(subject.prev_status.running?).to be true

        subject.status.success!
        is_expected.to be_success
        expect(subject.prev_status.failure?).to be true
      end
    end

    context 'ticked 0 times' do
      it { is_expected.to have_been_running_for_ticks 0 }
      it { is_expected.to be_success }
    end

    context 'ticked 1 times' do
      before { subject.tick! }

      it { is_expected.to have_been_running_for_ticks 1 }
      it { is_expected.to be_running }
    end

    context 'ticked 2 times' do
      before { 2.times { subject.tick! } }

      it { is_expected.to have_been_running_for_ticks 2 }
      it { is_expected.to be_success }
    end

    context 'ticked 3 times' do
      before { 3.times { subject.tick! } }

      it { is_expected.to have_been_running_for_ticks 1 }
      it { is_expected.to be_running }
    end
  end

  context 'when should_tick? implementation is wrong' do
    let(:custom_node) { CustomNodes::WrongShouldTick.new }
    it do
      expect { custom_node.tick! }
        .to raise_error(BehaviorTree::ShouldTickNotBooleanError).with_message(/0 \(Integer\)/)
    end
  end
end
