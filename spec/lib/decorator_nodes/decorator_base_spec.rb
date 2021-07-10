# frozen_string_literal: true

describe BehaviorTree::Decorators.const_get(:DecoratorBase) do
  let(:initialize_child_argument) { BehaviorTree.const_get(:Node).new }
  subject { described_class.new initialize_child_argument }

  describe '.initialize' do
    context 'argument has incorrect type' do
      let(:initialize_child_argument) { [1, 2, 3] }
      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'argument has correct type' do
      it { expect { subject }.to_not raise_error }
    end
  end

  describe '.tick!' do
    it { expect { subject.tick! }.to raise_error NotImplementedError }
  end
end
