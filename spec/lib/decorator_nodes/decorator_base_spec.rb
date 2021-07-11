# frozen_string_literal: true

describe BehaviorTree::Decorators.const_get(:DecoratorBase) do
  let(:child) { BehaviorTree.const_get(:NodeBase).new }
  subject { described_class.new child }

  describe '.initialize' do
    context 'argument has incorrect type' do
      let(:child) { [1, 2, 3] }
      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'argument has correct type' do
      it { expect { subject }.to_not raise_error }
    end
  end

  describe '.tick!' do
    before { subject.tick! }
    it { is_expected.to have_children_ticked_times [1] }
  end
end
