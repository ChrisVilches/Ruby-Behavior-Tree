# frozen_string_literal: true

describe BehaviorTree::NodeIterators::PrioritizeRunning do
  subject { BehaviorTree.const_get(:ControlNodeBase).new }

  describe '.prioritize_running' do
    context 'has some children' do
      let(:nops) { [BehaviorTree::Nop.new, BehaviorTree::Nop.new] }

      before { subject << nops }

      it { expect(subject.prioritize_running).to be_instance_of Enumerator }
      it { expect(subject.prioritize_running.to_a).to eq nops }
      it { expect(subject.prioritize_running.count).to eq 2 }
      it { expect(subject.prioritize_running.map(&:itself)).to eq nops }

      it 'can chain each' do
        values = []
        subject.prioritize_running.each { |v| values << v }
        expect(values).to eq nops
      end

      context 'first one is success, second one is running' do
        before do
          subject.children[0].status.success!
          subject.children[1].status.running!
        end

        # Skip first node.
        it { expect(subject.prioritize_running.count).to eq 1 }
        it { expect(subject.prioritize_running.first).to eq nops[1] }
      end
    end
  end
end
