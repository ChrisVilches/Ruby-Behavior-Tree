# frozen_string_literal: true

require_relative '../loader'

describe BehaviorTree::Sequence do
  pending
=begin
  let(:nop1) { BehaviorTree::Nop.new(1) }
  let(:nop2) { BehaviorTree::Nop.new(2) }
  let(:children) { subject.send(:children) }
  subject { described_class.new(children) }

  describe '.tick!' do
    context 'has one child (requires 2 ticks)' do
      let(:children) { [nop2] }

      context 'no ticks yet' do
        it_behaves_like 'status is success'
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it_behaves_like 'status is running'
        it_behaves_like 'all children have running status'
      end
    end

    context 'has two children (nop operations that require 1 and 2 ticks to complete respectively)' do
      let(:children) { [nop1, nop2] }

      context 'no ticks yet' do
        it_behaves_like 'status is success'
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it_behaves_like 'status is success'
        it_behaves_like 'all children have success status' # One completes, therefore halts all others.
      end
    end
  end
=end
end
