# frozen_string_literal: true

describe BehaviorTree::NodeIterators::AllNodes do
  subject { BehaviorTree.const_get(:ControlNodeBase).new(traversal_strategy: :all_nodes) }

  describe '.all_nodes' do
    context 'has some children' do
      let(:nops) { [BehaviorTree::Nop.new, BehaviorTree::Nop.new] }
      before { subject << nops }
      it { expect(subject.prioritize_non_success).to be_instance_of Enumerator }
      it { expect(subject.prioritize_non_success.map(&:itself)).to eq nops }
    end
  end
end
