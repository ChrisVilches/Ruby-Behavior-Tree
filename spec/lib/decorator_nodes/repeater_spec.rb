# frozen_string_literal: true

describe BehaviorTree::Decorators::Repeater do
  let(:nop_necessary_ticks) { 1 }
  let(:completes_with_failure) { false }
  let(:initialize_child_argument) do
    BehaviorTree::Nop.new(nop_necessary_ticks, completes_with_failure: completes_with_failure)
  end
  let(:max) { 3 }
  subject { described_class.new initialize_child_argument, max }

  describe '.decorate' do
    context 'child returns success' do
      before { subject.tick! }
      it { is_expected.to be_success }
      it { is_expected.to have_children_ticked_times [3] }
    end

    context 'child constantly returns failure' do
      let(:completes_with_failure) { true }
      before { subject.tick! }
      it { is_expected.to be_failure }
      it { is_expected.to have_children_ticked_times [1] }
    end

    context 'child needs two ticks to complete' do
      let(:nop_necessary_ticks) { 2 }
      before { subject.tick! }

      context 'ticked once' do
        # Since after the first tick it returns running, the loop does not continue.
        it { is_expected.to have_children_ticked_times [1] }
        it { is_expected.to be_running }
      end

      context 'ticked twice' do
        before { subject.tick! }
        # When ticked the second time, it completes with success, and the retry
        # kicks in. The retry ticks it once more, and it becomes running (stop retry and return).
        it { is_expected.to have_children_ticked_times [3] }
        it { is_expected.to be_running }
        context 'completes with failure status' do
          let(:completes_with_failure) { true }
          it { is_expected.to have_children_ticked_times [2] }
          it { is_expected.to be_failure }
        end
      end
    end
  end
end
