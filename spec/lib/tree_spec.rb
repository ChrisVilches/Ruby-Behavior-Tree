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
        it 'safely chains the chainable node, not the tree itself' do
          # This is explained below in the "describe '.chainable_node'" tests.
          expect { subject }.to_not raise_error
        end
      end

      context 'invalid main node' do
        it { expect { described_class.new([1, 2]) }.to raise_error BehaviorTree::InvalidTreeMainNodeError }
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

  describe '.chainable_node' do
    let(:child) { nop_fail }
    context 'chaining tree to control node' do
      before { selector << tree }
      it 'chains the tree in a flattened way' do
        added_child = selector.instance_variable_get(:@children).last
        expect(added_child).to eq nop_fail
      end
    end

    context 'chaining tree to decorator node' do
      let(:repeater) { BehaviorTree::Decorators::Repeater.new(tree, 10) }
      it 'chains the tree in a flattened way' do
        decorator_child = repeater.instance_variable_get(:@child)
        expect(decorator_child).to eq nop_fail
      end
    end

    context 'chaining tree to another tree' do
      let(:new_tree) { BehaviorTree::Tree.new(tree) }
      it { expect(new_tree.child).to eq nop_fail }
    end
  end

  describe '.uniq_nodes?' do
    pending
  end

  describe '.dag?' do
    pending
  end
end
