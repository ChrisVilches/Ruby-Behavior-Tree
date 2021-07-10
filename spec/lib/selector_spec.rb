# frozen_string_literal: true

require_relative '../loader'

describe BehaviorTree::Selector do
  let(:nop2) { BehaviorTree::Nop.new(2) }
  let(:nop3) { BehaviorTree::Nop.new(3) }
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

      context 'has been ticked twice' do
        before { 2.times { subject.tick! } }
        it_behaves_like 'status is success'
        it_behaves_like 'all children have success status'
      end
    end

    context 'has two children (nop operations that require 2 and 3 ticks to complete respectively)' do
      let(:children) { [nop2, nop3] }

      context 'no ticks yet' do
        it_behaves_like 'status is success'
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it_behaves_like 'status is running'
        it_behaves_like 'all children have running status'
      end

      context 'has been ticked once' do
        before { 2.times { subject.tick! } }
        it_behaves_like 'status is success'
        it_behaves_like 'all children have success status' # One completes, therefore halts all others.
      end
    end
  end
end
