# frozen_string_literal: true

describe BehaviorTree::Decorators::Condition do
  let(:initial_context) { { a: 5 } }
  let(:condition) { proc { context[:a].positive? } }
  let(:child) do
    BehaviorTree::TaskBase.new do
      context[:a] -= 1
      status.running!
    end
  end
  subject { described_class.new child, &condition }

  # Propagate context down the tree.
  before { subject.context = initial_context }

  describe '.initialize' do
    context 'no block given' do
      it { expect { described_class.new child }.to raise_error(ArgumentError).with_message(/must be given a block/) }
    end

    context 'lambda given' do
      subject { described_class.new(child, -> {}) }
      it { expect { subject }.to_not raise_error }
      context 'block also given' do
        let(:invalid) { described_class.new(child, -> {}) { :empty_block } }
        it { expect { invalid }.to raise_error(ArgumentError).with_message(/not both/) }
      end
    end

    context 'proc given' do
      subject { described_class.new(child, proc {}) }
      it { expect { subject }.to_not raise_error }
      context 'block also given' do
        let(:invalid) { described_class.new(child, proc {}) { :empty_block } }
        it { expect { invalid }.to raise_error(ArgumentError).with_message(/not both/) }
      end
    end
  end

  pending 'Test the argument passing according to lambda arity'

  describe '.tick!' do
    context 'condition that prevents ticking after a few ticks' do
      context 'zero ticks' do
        it { is_expected.to be_success }
        it { expect(child.instance_variable_get(:@tick_count)).to eq 0 }
        it { expect(initial_context[:a]).to eq 5 }
      end

      context 'two ticks' do
        before { 2.times { subject.tick! } }
        it { is_expected.to be_running }
        it { expect(child.instance_variable_get(:@tick_count)).to eq 2 }
        it { expect(initial_context[:a]).to eq 3 }
      end

      context 'five ticks (condition kicks in)' do
        before { 5.times { subject.tick! } }
        it { is_expected.to be_running }
        it { expect(child.instance_variable_get(:@tick_count)).to eq 5 }
        it { expect(initial_context[:a]).to eq 0 }
      end

      context 'six ticks (last one failed)' do
        before { 6.times { subject.tick! } }
        it { is_expected.to be_failure }
        it { expect(child.instance_variable_get(:@tick_count)).to eq 5 }
        it { expect(initial_context[:a]).to eq 0 }
      end
    end
  end
end
