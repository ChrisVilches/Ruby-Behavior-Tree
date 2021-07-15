# frozen_string_literal: true

describe BehaviorTree::Builder do
  subject { tree }

  let(:initial_context) { { a: 5 } }
  let(:child) { tree.instance_variable_get(:@child) }

  let(:tree) do
    described_class.build do
      condition ->(context) { context[:a].positive? } do
        task do
          context[:a] -= 1
          status.running!
        end
      end
    end
  end

  # Propagate context down the tree.
  before { subject.context = initial_context }

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

        it 'increases tick count even if it failed' do
          expect(child.tick_count).to eq 6
        end

        it { expect(initial_context[:a]).to eq 0 }
      end
    end
  end
end
