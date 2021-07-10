# frozen_string_literal: true

describe BehaviorTree::NodeIterators::PrioritizeNonSuccess do
  subject { BehaviorTree::ControlFlowNode.new }

  describe '.non_success' do
    context 'has some children' do
      let(:nops) { [BehaviorTree::Nop.new, BehaviorTree::Nop.new] }
      before { subject << nops }
      it { expect(subject.non_success).to be_instance_of Enumerator }
      it { expect(subject.non_success.to_a).to eq nops }
      it { expect(subject.non_success.count).to eq 2 }
      it { expect(subject.non_success.map(&:itself)).to eq nops }

      it 'can chain each' do
        values = []
        subject.non_success.each { |v| values << v }
        expect(values).to eq nops
      end

      context 'first one is success, second one is running' do
        before do
          subject.instance_variable_get(:@children)[0].status.success!
          subject.instance_variable_get(:@children)[1].status.running!
        end

        # Skip first node.
        it { expect(subject.non_success.count).to eq 1 }
        it { expect(subject.non_success.first).to eq nops[1] }
      end
    end
  end
end
