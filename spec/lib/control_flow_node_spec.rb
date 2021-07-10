# frozen_string_literal: true

describe BehaviorTree::ControlFlowNode do
  subject { described_class.new([], strategy: :all_nodes) }
  let(:nops) { [BehaviorTree::Nop.new(1), BehaviorTree::Nop.new(2)] }
  before { subject << nops }

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
      expect(subject.send(:tick_each_children) {}).to eq nops
    end
    context 'having a block' do
      before { 10.times { subject.send(:tick_each_children) {} } }
      it { expect(subject).to have_children_ticked_times [10, 10] }
    end

    context 'not having a block' do
      before { 10.times { subject.send(:tick_each_children) } }
      it { expect(subject).to have_children_ticked_times [0, 0] }
    end
  end
end
