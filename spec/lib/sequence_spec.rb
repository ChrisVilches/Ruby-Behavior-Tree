# frozen_string_literal: true

require_relative '../loader'

describe BehaviorTree::Sequence do
  let(:nop1) { BehaviorTree::Nop.new(1, completes_with_failure: completes_with_failure) }
  let(:nop2) { BehaviorTree::Nop.new(2, completes_with_failure: completes_with_failure) }
  let(:nop3) { BehaviorTree::Nop.new(3, completes_with_failure: completes_with_failure) }
  let(:children) { subject.send(:children) }
  subject { described_class.new(children) }

  describe '.tick!' do
    context 'has one child (requires 2 ticks)' do
      let(:completes_with_failure) { false }
      let(:children) { [nop2] }

      context 'no ticks yet' do
        it { expect(subject).to be_success }
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it { expect(subject).to be_running }
        it { expect(subject).to have_children_statuses :running }
      end

      context 'has been ticked twice' do
        before { 2.times { subject.tick! } }
        it { expect(subject).to be_success }
        it { expect(subject).to have_children_statuses :success }

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }
          it { expect(subject).to be_failure }
          it { expect(subject).to have_children_statuses :failure }
        end
      end
    end

    context 'has two children (nop operations that require 2 and 3 ticks to complete respectively)' do
      let(:completes_with_failure) { false }
      let(:children) { [nop2, nop3] }

      context 'no ticks yet' do
        it { expect(subject).to be_success }
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it { expect(subject).to be_running }
        it "gets 'running' status from the first node, so it does not tick the second node" do
          expect(subject).to have_children_statuses %i[running success]
        end
      end

      context 'has been ticked twice' do
        before { 2.times { subject.tick! } }
        it { expect(subject).to be_running } # One completes, but needs others to complete.
        it 'has completed only one child' do
          expect(subject).to have_children_statuses %i[success running]
        end

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }
          it { expect(subject).to be_failure }
          it 'has one child with failure status' do
            # Both nop operations were set to finish with failure,
            # but only the first one finishes, because it was only
            # ticked twice before checking this.
            expect(subject).to have_children_statuses %i[failure running]
          end
        end
      end

      context 'has been ticked three times' do
        before { 3.times { subject.tick! } }
        it { expect(subject).to be_success }
        it 'completes the first node so it gets resetted, and the second node just completes' do
          expect(subject).to have_children_statuses %i[running failure]
        end
      end
    end
  end
end
