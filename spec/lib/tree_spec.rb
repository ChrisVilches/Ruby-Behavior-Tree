# frozen_string_literal: true

describe BehaviorTree::Tree do
  let(:nop_fail) { BehaviorTree::Nop.new(2, completes_with_failure: true) }
  let(:nop_success) { BehaviorTree::Nop.new(2) }
  let(:selector) { BehaviorTree::Selector.new }
  before { selector << [nop_fail, nop_success] }
  let(:tree) { BehaviorTree::Tree.new(child) }
  subject { tree }
  describe '.new' do
    context 'empty argument' do
      let(:child) { nil }
      it { expect { subject }.to raise_error BehaviorTree::InvalidLeafNodeError }
    end

    context 'has argument' do
      context 'argument is tree' do
        let(:child) { BehaviorTree::Tree.new(nop_fail) }
        it { expect { subject }.to raise_error BehaviorTree::InvalidTreeMainNodeError }
      end
    end
  end

  describe '.tick' do
    context 'nop fail main node' do
      let(:child) { nop_fail }
      context 'ticked once' do
        before { tree.tick! }
        it { is_expected.to be_running }
      end

      context 'ticked twice' do
        before { 2.times { tree.tick! } }
        it { is_expected.to be_failure }
      end
    end

    context 'nop success main node' do
      let(:child) { nop_success }
      context 'ticked once' do
        before { tree.tick! }
        it { is_expected.to be_running }
      end

      context 'ticked twice' do
        before { 2.times { tree.tick! } }
        it { is_expected.to be_success }
      end
    end

    context 'selector main node' do
      let(:child) { selector }
      context 'ticked once' do
        before { tree.tick! }
        it { is_expected.to be_running }
      end

      context 'ticked twice' do
        # Trace:
        # Tick #1: Ticks only the first node (running).
        # Tick #2: Ticks the first node (failure, so continues), ticks the second one (running).
        before { 2.times { tree.tick! } }
        it { is_expected.to be_running }
      end
    end
  end

  describe '.concat' do
    pending
  end
end
