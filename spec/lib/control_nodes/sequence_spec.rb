# frozen_string_literal: true

describe BehaviorTree::Sequence do
  let(:nop2) { BehaviorTree::Nop.new(2, completes_with_failure: completes_with_failure) }
  let(:nop3) { BehaviorTree::Nop.new(3, completes_with_failure: completes_with_failure) }
  let(:children) { subject.send(:children) }
  subject { described_class.new(children) }
  let(:nop_fail) { BehaviorTree::Nop.new(2, completes_with_failure: true) }

  let(:nop_success1) { BehaviorTree::Nop.new(2, completes_with_failure: false) }
  let(:nop_success2) { BehaviorTree::Nop.new(2, completes_with_failure: false) }
  let(:nop_success3) { BehaviorTree::Nop.new(2, completes_with_failure: false) }

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
          it 'halts children' do
            is_expected.to have_children_statuses :success
          end
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
          it { is_expected.to have_children_ticked_times [2, 0] }
          it 'halts children' do
            is_expected.to have_children_statuses %i[success success]
          end
        end
      end

      context 'has been ticked three times' do
        before { 3.times { subject.tick! } }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[success running] }

        # Trace:
        # Tick #1: Tick first node (running, so stop).
        # Tick #2: Tick first node (success, so continue), tick second node.
        # Tick #3: Start from running nodes, so tick only second node.
        it { is_expected.to have_children_ticked_times [2, 2] }

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }
          it { is_expected.to be_running }
          it { is_expected.to have_children_statuses %i[running success] }
          it { is_expected.to have_children_ticked_times [3, 0] }
        end
      end
    end

    context 'executes all in sequence' do
      # TODO: Errors due to objects that are unable to deep-clone are present.
      #       Must refactor this.
      let(:children) { [nop_success1, nop_success2, nop_success3].map(&:dup) }
      context '1 tick' do
        before { subject.tick! }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success success] }
        it { is_expected.to have_children_ticked_times [1, 0, 0] }
      end

      context '2 tick' do
        before { 2.times { subject.tick! } }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[success running success] }
        it { is_expected.to have_children_ticked_times [2, 1, 0] }
      end

      context '3 tick' do
        before { 3.times { subject.tick! } }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[success success running] }
        it { is_expected.to have_children_ticked_times [2, 2, 1] }
      end

      context '4 tick' do
        before { 4.times { subject.tick! } }
        it { is_expected.to be_success }
        it { is_expected.to have_children_statuses %i[success success success] }
        it { is_expected.to have_children_ticked_times [2, 2, 2] }
      end

      context '5 tick' do
        before { 5.times { subject.tick! } }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success success] }
        it { is_expected.to have_children_ticked_times [3, 2, 2] }
      end
    end

    context 'second operation fails' do
      let(:children) { [nop_success1, nop_fail, nop_success2].map(&:dup) }
      context '1 tick' do
        before { subject.tick! }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success success] }
        it { is_expected.to have_children_ticked_times [1, 0, 0] }
      end

      context '2 tick' do
        before { 2.times { subject.tick! } }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[success running success] }
        it { is_expected.to have_children_ticked_times [2, 1, 0] }
      end

      context '3 tick' do
        before { 3.times { subject.tick! } }
        it { is_expected.to be_failure }
        it { is_expected.to have_children_statuses %i[success success success] } # Halted.
        it { is_expected.to have_children_ticked_times [2, 2, 0] }
      end

      context '4 tick' do
        before { 4.times { subject.tick! } }
        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success success] }
        it { is_expected.to have_children_ticked_times [3, 2, 0] }
      end
    end
  end
end
