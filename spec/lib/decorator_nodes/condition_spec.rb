# frozen_string_literal: true

describe BehaviorTree::Decorators::Condition do
  subject { described_class.new child, &condition }

  let(:initial_context) { { a: 5 } }
  let(:condition) { ->(context) { context[:a].positive? } }
  let(:child) do
    BehaviorTree::TaskBase.new do
      context[:a] -= 1
      status.running!
    end
  end

  # Propagate context down the tree.
  before { subject.context = initial_context }

  describe '.initialize' do
    context 'no block given' do
      it { expect { described_class.new child }.not_to raise_error }
    end

    context 'lambda given' do
      subject { described_class.new child, fn }

      let(:fn) { -> {} }

      it { expect { subject }.not_to raise_error }

      context 'block also given' do
        let(:invalid) { described_class.new(child, fn) { :empty_block } }

        it { expect { invalid }.to raise_error(ArgumentError).with_message(/not both/) }
      end

      # These lambdas trigger an error if the data IS defined, so by catching those
      # errors (with specific message), it validates that the lambda's are executed, and
      # the data is passed properly.
      context 'given lambda with only context' do
        let(:fn) { ->(context) { raise 'context defined' if context[:a] == 5 } }

        it { expect { subject.tick! }.to raise_error.with_message('context defined') }
      end

      context 'given lambda with context and node' do
        let(:fn) { ->(_context, node) { raise 'condition node defined' if node.is_a?(described_class) } }

        it { expect { subject.tick! }.to raise_error.with_message('condition node defined') }
      end

      context 'using a normal block (with an impossible condition)' do
        subject { described_class.new(child) { context[:a] == 100 } }

        before { subject.tick! }

        it { is_expected.to be_failure }
      end

      context 'using a normal block (with a successful condition)' do
        subject { described_class.new(child) { context[:a] == 5 } }

        before { subject.tick! }

        it { is_expected.to be_running } # NOTE: Copies the child status (task always sets it to running).
      end
    end

    context 'proc given' do
      subject { described_class.new(child, proc {}) }

      it { expect { subject }.not_to raise_error }

      context 'block also given' do
        let(:invalid) { described_class.new(child, proc {}) { :empty_block } }

        it { expect { invalid }.to raise_error(ArgumentError).with_message(/not both/) }
      end
    end

    context 'nothing given' do
      subject { described_class.new child }

      before { subject.tick! }

      it 'defaults to false' do
        expect(subject).to be_failure
        expect(subject.instance_variable_get(:@tick_prevented)).to be true
      end
    end
  end

  describe '.tick!' do
    context 'condition that prevents ticking after a few ticks' do
      context 'zero ticks' do
        it { is_expected.to be_success }
        it { expect(child.tick_count).to eq 0 }
        it { expect(initial_context[:a]).to eq 5 }
      end

      context 'two ticks' do
        before { 2.times { subject.tick! } }

        it { is_expected.to be_running }
        it { expect(child.tick_count).to eq 2 }
        it { expect(initial_context[:a]).to eq 3 }
      end

      context 'five ticks (condition kicks in)' do
        before { 5.times { subject.tick! } }

        it { is_expected.to be_running }
        it { expect(child.tick_count).to eq 5 }
        it { expect(initial_context[:a]).to eq 0 }
      end

      context 'six ticks (last one failed)' do
        before { 6.times { subject.tick! } }

        it { is_expected.to be_failure }
        it { expect(child.tick_count).to eq 5 }
        it { expect(initial_context[:a]).to eq 0 }
      end
    end
  end

  describe '.halt!' do
    before { child.status.running! }

    before { subject.halt! }

    it { is_expected.to be_success }
    it { expect(child).to be_success }
  end
end
