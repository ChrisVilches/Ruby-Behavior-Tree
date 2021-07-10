# frozen_string_literal: true

describe BehaviorTree::Decorators::Retry do
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
      it { is_expected.to have_children_ticked_times [1] }
    end

    context 'child constantly returns failure' do
      let(:completes_with_failure) { true }
      before { subject.tick! }
      it { is_expected.to be_failure }
      it { is_expected.to have_children_ticked_times [3] }
    end

    context 'child returns failure at the second tick' do
      let(:completes_with_failure) { true }
      let(:nop_necessary_ticks) { 2 }
      before { subject.tick! }
      # Since after the first tick it returns running, the loop does not continue.
      it { is_expected.to have_children_ticked_times [1] }
    end
  end
end
