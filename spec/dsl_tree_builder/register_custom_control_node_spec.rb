# frozen_string_literal: true

module CustomControlNodes
  class TickOnlySecondNode < BehaviorTree::ControlNodeBase
    children_traversal_strategy :only_middle

    private

    def only_middle
      Enumerator.new do |y|
        y << @children[1]
      end
    end

    def on_tick
      tick_each_children do
        status.success!
      end
    end
  end
end

describe BehaviorTree::Builder do
  let(:tree) do
    described_class.build do
      tick_only_second_node do
        t { context[:a] += 1 }
        t { context[:b] += 1 }
        t { context[:c] += 1 }
      end
    end
  end

  before { tree.context = { a: 0, b: 0, c: 0 } }
  subject { tree }

  describe '.register' do
    context 'registered a new control node' do
      before :all do
        described_class.register(
          :tick_only_second_node,
          'CustomControlNodes::TickOnlySecondNode',
          children: :multiple
        )
      end

      before { 5.times { subject.tick! } }

      it { expect(tree.context).to eq({ a: 0, b: 5, c: 0 }) }
    end
  end
end
