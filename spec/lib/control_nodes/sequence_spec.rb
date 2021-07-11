# frozen_string_literal: true

describe BehaviorTree::Sequence do
  let(:nop2) { BehaviorTree::Nop.new(2, completes_with_failure: completes_with_failure) }
  let(:nop3) { BehaviorTree::Nop.new(3, completes_with_failure: completes_with_failure) }
  let(:children) { subject.send(:children) }
  subject { described_class.new(children) }

  describe '.tick!' do
    context 'has one child (requires 2 ticks)' do
      let(:completes_with_failure) { false }
      let(:children) { [nop2] }

      context 'no ticks yet' do
        it { is_expected.to be_success }
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses :running }
      end

      context 'has been ticked twice' do
        before { 2.times { subject.tick! } }
        it { is_expected.to be_success }
        it { is_expected.to have_children_statuses :success }

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }
          it { is_expected.to be_failure }
          it { is_expected.to have_children_statuses :failure }
        end
      end
    end

    context 'has two children (nop operations that require 2 and 3 ticks to complete respectively)' do
      let(:completes_with_failure) { false }
      let(:children) { [nop2, nop3] }

      context 'no ticks yet' do
        it { is_expected.to be_success }
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success] }
        it { is_expected.to have_children_ticked_times [1, 0] }
      end

      context 'has been ticked twice' do
        before { 2.times { subject.tick! } }
        it { is_expected.to be_running } # One completes, but needs others to complete.
        it { is_expected.to have_children_statuses %i[success running] }
        it { is_expected.to have_children_ticked_times [2, 1] }

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }
          it { is_expected.to be_failure }
          it { is_expected.to have_children_statuses %i[failure success] }
          it { is_expected.to have_children_ticked_times [2, 0] }
        end
      end

      context 'has been ticked three times' do
        before { 3.times { subject.tick! } }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[success running] }

        # Trace:
        # Tick #1: Tick first node (running, so stop).
        # Tick #2: Tick first node (success, so continue), tick second node.
        # Tick #3: Start from non-success nodes, so tick only second node.
        it { is_expected.to have_children_ticked_times [2, 2] }

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }
          it { is_expected.to be_running }
          it { is_expected.to have_children_statuses %i[running success] }
          it { is_expected.to have_children_ticked_times [3, 0] }
        end
      end
    end
  end
end
