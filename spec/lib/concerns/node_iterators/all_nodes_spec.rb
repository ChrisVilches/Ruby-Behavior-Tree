# frozen_string_literal: true

module TestControlNodes
  class AllNodes < BehaviorTree::ControlNodeBase
    children_traversal_strategy :all_nodes
    def on_tick; end
  end
end

describe BehaviorTree::NodeIterators::AllNodes do
  subject { TestControlNodes::AllNodes.new }

  describe '.all_nodes' do
    context 'has some children' do
      let(:nops) { [BehaviorTree::Nop.new, BehaviorTree::Nop.new] }

      before { subject << nops }

      it { expect(subject.all_nodes).to be_instance_of Enumerator }
      it { expect(subject.all_nodes.map(&:itself)).to eq nops }
    end
  end
end
