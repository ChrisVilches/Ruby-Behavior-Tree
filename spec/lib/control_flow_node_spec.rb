# frozen_string_literal: true

describe BehaviorTree.const_get(:ControlFlowNode) do
  let(:traversal_strategy) { :all_nodes }
  subject { described_class.new([], traversal_strategy: traversal_strategy) }
  let(:nops) { [BehaviorTree::Nop.new(1), BehaviorTree::Nop.new(2)] }
  before { subject << nops }

  describe '.initialize' do
    context 'traversal strategy is wrong' do
      it { expect { described_class.new([], traversal_strategy: :dont_exist) }.to raise_error NoMethodError }
    end
  end

  describe '.tick_each_children' do
    it { expect(subject.send(:tick_each_children)).to be_instance_of Enumerator }
    it { expect(subject.send(:tick_each_children).each).to be_instance_of Enumerator }
    it 'can chain filter' do
      filtered = subject.send(:tick_each_children).filter do |child|
        child.instance_variable_get(:@necessary_ticks) == 2
      end
      expect(filtered).to eq [nops[1]]
    end
    it 'returns the array when using a block' do
      expect(subject.send(:tick_each_children) { |x| x }).to eq nops
    end
    context 'having a block' do
      before { 10.times { subject.send(:tick_each_children) { |x| x } } }
      it { is_expected.to have_children_ticked_times [10, 10] }
    end

    context 'not having a block' do
      before { 10.times { subject.send(:tick_each_children) } }
      it { is_expected.to have_children_ticked_times [0, 0] }
    end

    context 'without children' do
      let(:nops) { [] }
      it do
        expect { subject.send(:tick_each_children) { |x| x } }.to raise_error BehaviorTree::InvalidLeafNodeError
      end
    end
  end

  describe '.validate_enum!' do
    let(:traversal_strategy) { :to_s }
    it do
      expect do
        subject.send(:tick_each_children) { |x| x }
      end.to raise_error BehaviorTree::IncorrectTraversalStrategyError
    end
  end
end
