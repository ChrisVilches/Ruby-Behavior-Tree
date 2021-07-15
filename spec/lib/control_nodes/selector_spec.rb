# frozen_string_literal: true

describe BehaviorTree::Selector do
  subject { described_class.new(children) }

  let(:completes_with_failure) { false }
  let(:nop_success) { BehaviorTree::Nop.new(2, completes_with_failure: false) }
  let(:nop_fail1) { BehaviorTree::Nop.new(2, completes_with_failure: true) }
  let(:nop_fail2) { BehaviorTree::Nop.new(2, completes_with_failure: true) }
  let(:nop_fail3) { BehaviorTree::Nop.new(2, completes_with_failure: true) }
  let(:nop2) { BehaviorTree::Nop.new(2, completes_with_failure: completes_with_failure) }
  let(:nop3) { BehaviorTree::Nop.new(3, completes_with_failure: completes_with_failure) }
  let(:children) { subject.children }

  describe '.tick!' do
    context 'has one child (requires 2 ticks)' do
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
      end
    end

    context 'has two children (nop operations that require 2 and 3 ticks to complete respectively)' do
      let(:children) { [nop2, nop3] }

      context 'no ticks yet' do
        it { is_expected.to be_success }
        it { is_expected.to have_children_ticked_times [0, 0] }
      end

      context 'has been ticked once' do
        before { subject.tick! }

        it { is_expected.to be_running }

        it "gets 'running' status from child, so the next child is not ticked yet" do
          expect(subject).to have_children_statuses %i[running success]
        end

        it { is_expected.to have_children_ticked_times [1, 0] }
      end

      context 'has been ticked twice' do
        before { 2.times { subject.tick! } }

        it { is_expected.to be_success }
        it { is_expected.to have_children_statuses :success }
        it { is_expected.to have_children_ticked_times [2, 0] }

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }

          it { is_expected.to be_running }
          it { is_expected.to have_children_statuses %i[failure running] }
          it { is_expected.to have_children_ticked_times [2, 1] }
        end
      end

      context 'has been ticked three times' do
        before { 3.times { subject.tick! } }

        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success] }
        it { is_expected.to have_children_ticked_times [3, 0] }

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }

          it { is_expected.to be_running }
          it { is_expected.to have_children_statuses %i[failure running] }

          # Trace:
          # Tick #1: Tick first node (running, so stop).
          # Tick #2: Tick first node (failure, so continue), tick second node.
          # Tick #3: Start from running nodes, so tick second one (running, so stop).
          it { is_expected.to have_children_ticked_times [2, 2] }
        end
      end
    end

    context 'no operation is selected (all fail)' do
      let(:children) { [nop_fail1, nop_fail2, nop_fail3] }

      context '1 tick' do
        before { subject.tick! }

        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success success] }
        it { is_expected.to have_been_running_for_ticks 1 }
        it { is_expected.to have_children_running_for_ticks [1, 0, 0] }
        it { is_expected.to have_children_ticked_times [1, 0, 0] }
      end

      context '2 tick' do
        before { 2.times { subject.tick! } }

        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[failure running success] }
        it { is_expected.to have_been_running_for_ticks 2 }
        it { is_expected.to have_children_running_for_ticks [2, 1, 0] }
        it { is_expected.to have_children_ticked_times [2, 1, 0] }
      end

      context '3 tick' do
        before { 3.times { subject.tick! } }

        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[failure failure running] }
        it { is_expected.to have_been_running_for_ticks 3 }
        it { is_expected.to have_children_running_for_ticks [2, 2, 1] }
        it { is_expected.to have_children_ticked_times [2, 2, 1] }
      end

      context '4 tick' do
        before { 4.times { subject.tick! } }

        it { is_expected.to be_failure }
        it { is_expected.to have_children_statuses %i[success success success] } # Halted.
        it { is_expected.to have_been_running_for_ticks 4 }
        it { is_expected.to have_children_running_for_ticks [2, 2, 2] }
        it { is_expected.to have_children_ticked_times [2, 2, 2] }
      end

      context '5 tick' do
        before { 5.times { subject.tick! } }

        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success success] }
        it { is_expected.to have_been_running_for_ticks 1 }
        it { is_expected.to have_children_running_for_ticks [1, 2, 2] }
        it { is_expected.to have_children_ticked_times [3, 2, 2] }
      end
    end

    context 'second operation is selected' do
      let(:children) { [nop_fail1, nop_success, nop_fail2] }

      context '1 tick' do
        before { subject.tick! }

        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success success] }
        it { is_expected.to have_been_running_for_ticks 1 }
        it { is_expected.to have_children_running_for_ticks [1, 0, 0] }
        it { is_expected.to have_children_ticked_times [1, 0, 0] }
      end

      context '2 tick' do
        before { 2.times { subject.tick! } }

        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[failure running success] }
        it { is_expected.to have_been_running_for_ticks 2 }
        it { is_expected.to have_children_running_for_ticks [2, 1, 0] }
        it { is_expected.to have_children_ticked_times [2, 1, 0] }
      end

      context '3 tick' do
        before { 3.times { subject.tick! } }

        it { is_expected.to be_success }
        it { is_expected.to have_children_statuses %i[success success success] } # Halted.
        it { is_expected.to have_been_running_for_ticks 3 }
        it { is_expected.to have_children_running_for_ticks [2, 2, 0] }
        it { is_expected.to have_children_ticked_times [2, 2, 0] }
      end

      context '4 tick' do
        before { 4.times { subject.tick! } }

        it { is_expected.to be_running }
        it { is_expected.to have_children_statuses %i[running success success] }
        it { is_expected.to have_been_running_for_ticks 1 }
        it { is_expected.to have_children_running_for_ticks [1, 2, 0] }
        it { is_expected.to have_children_ticked_times [3, 2, 0] }
      end

      context '5 tick' do
        before { 5.times { subject.tick! } }

        it { is_expected.to be_running }
        it { is_expected.to have_been_running_for_ticks 2 }
        it { is_expected.to have_children_running_for_ticks [2, 1, 0] }
        it { is_expected.to have_children_ticked_times [4, 3, 0] }
      end

      context '6 tick' do
        before { 6.times { subject.tick! } }

        it { is_expected.to be_success }
        it { is_expected.to have_been_running_for_ticks 3 }
        it { is_expected.to have_children_running_for_ticks [2, 2, 0] }
        it { is_expected.to have_children_ticked_times [4, 4, 0] }
      end
    end
  end
end
