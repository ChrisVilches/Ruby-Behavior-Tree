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
        it_behaves_like 'status is success'
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it_behaves_like 'status is running'
        it_behaves_like 'all children have running status'
      end

      context 'has been ticked twice' do
        before { 2.times { subject.tick! } }
        it_behaves_like 'status is success'
        it_behaves_like 'all children have success status'

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }
          it_behaves_like 'status is failure'
          it_behaves_like 'all children have failure status'
        end
      end
    end

    context 'has two children (nop operations that require 2 and 3 ticks to complete respectively)' do
      let(:completes_with_failure) { false }
      let(:children) { [nop2, nop3] }

      context 'no ticks yet' do
        it_behaves_like 'status is success'
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it_behaves_like 'status is running'
        it_behaves_like 'all children have running status'
      end

      context 'has been ticked twice' do
        before { 2.times { subject.tick! } }
        it_behaves_like 'status is running' # One completes, but needs others to complete.
        it 'has completed only one child' do
          children = subject.instance_variable_get(:@children)
          expect(children[0].status.success?).to be true
          expect(children[1].status.running?).to be true
        end

        context 'nop operation ends with failure' do
          let(:completes_with_failure) { true }
          it_behaves_like 'status is failure'
          it 'has one child with failure status' do
            # Both nop operations were set to finish with failure,
            # but only the first one finishes, because it was only
            # ticked twice before checking this.
            children = subject.instance_variable_get(:@children)
            expect(children[0].status.failure?).to be true
            expect(children[1].status.running?).to be true
          end
        end
      end

      context 'has been ticked three times' do
        before { 3.times { subject.tick! } }
        it_behaves_like 'status is success'
        it_behaves_like 'all children have success status'
      end
    end
  end
end
