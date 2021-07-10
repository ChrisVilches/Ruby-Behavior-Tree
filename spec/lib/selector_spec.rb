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
      end
    end

    context 'has two children (nop operations that require 2 and 3 ticks to complete respectively)' do
      let(:children) { [nop2, nop3] }

      context 'no ticks yet' do
        it { expect(subject).to be_success }
      end

      context 'has been ticked once' do
        before { subject.tick! }
        it { expect(subject).to be_running }
        it "gets 'running' status from child, so the next child is not ticked yet" do
          expect(subject).to have_children_statuses %i[running success]
        end
      end

      context 'has been ticked once' do
        before { 2.times { subject.tick! } }
        it { expect(subject).to be_success }
        it { expect(subject).to have_children_statuses :success } # One completes, therefore halts all others.
      end
    end
  end
end
