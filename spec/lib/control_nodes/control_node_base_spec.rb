# frozen_string_literal: true

module TestControlNodes
  class OnTickNotImplemented < BehaviorTree::ControlNodeBase; end

  class StrategyNotExists < BehaviorTree::ControlNodeBase
    children_traversal_strategy :not_exists
    def on_tick; end
  end

  class StrategyToString < BehaviorTree::ControlNodeBase
    children_traversal_strategy :to_s
    def on_tick; end
  end

  class AllNodes < BehaviorTree::ControlNodeBase
    children_traversal_strategy :all_nodes
    def on_tick; end
  end

  class MySelector < BehaviorTree::Selector; end
end

describe BehaviorTree.const_get(:ControlNodeBase) do
  let(:nops) { [BehaviorTree::Nop.new(1), BehaviorTree::Nop.new(2)] }

  describe '.initialize' do
    context 'traversal strategy is wrong' do
      it do
        expect do
          TestControlNodes::StrategyNotExists.new(nops)
        end.to raise_error(BehaviorTree::IncorrectTraversalStrategyError)
          .with_message(/Attempted to use strategy: not_exists\./)
      end
    end
  end

  describe '.on_tick' do
    context 'child class has not implemented on_tick method' do
      it do
        expect do
          TestControlNodes::OnTickNotImplemented.new(nops).tick!
        end.to raise_error(NotImplementedError).with_message('Must implement control logic')
      end
    end

    context 'child class inherits from selector and has no explicitly defined traversal strategy' do
      subject { TestControlNodes::MySelector.new(nops) }
      it 'inherits on_tick implementation (does not raise NotImplementedError)' do
        expect { subject.send :on_tick }.to_not raise_error
      end

      it 'checks entire class hierarchy (not just parent) to find a default traversal_strategy' do
        expect(subject.class.traversal_strategy).to eq :prioritize_running
        expect(subject.send(:traversal_strategy)).to eq :prioritize_running
      end
    end
  end

  describe '.validate_enum!' do
    subject { TestControlNodes::StrategyToString.new(nops) }
    it do
      expect do
        subject.send(:tick_each_children) { :empty_block }
      end.to raise_error BehaviorTree::IncorrectTraversalStrategyError
    end
  end

  describe '.tick_each_children' do
    subject { TestControlNodes::AllNodes.new(nops) }

    it { expect(subject.send(:tick_each_children)).to be_instance_of Enumerator }
    it { expect(subject.send(:tick_each_children).each).to be_instance_of Enumerator }
    it 'can chain filter' do
      filtered = subject.send(:tick_each_children).filter do |child|
        child.instance_variable_get(:@necessary_ticks) == 2
      end
      expect(filtered).to eq [nops[1]]
    end
    it 'returns the array when using a block' do
      expect(subject.send(:tick_each_children) { :empty_block }).to eq nops
    end

    context 'having a block' do
      before { 10.times { subject.send(:tick_each_children) { :empty_block } } }
      it { is_expected.to have_children_ticked_times [10, 10] }
    end

    context 'not having a block' do
      before { 10.times { subject.send(:tick_each_children) } }
      it { is_expected.to have_children_ticked_times [0, 0] }
    end
    context 'without children' do
      let(:nops) { [] }
      context 'with block' do
        it do
          expect do
            subject.send(:tick_each_children) { :empty_block }
          end.to raise_error BehaviorTree::InvalidLeafNodeError
        end
      end
      context 'without block' do
        it { expect { subject.send(:tick_each_children) }.to_not raise_error }
      end
    end
  end
end
