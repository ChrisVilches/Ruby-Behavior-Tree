# frozen_string_literal: true

describe BehaviorTree::Decorators.const_get(:RepeatTimesBase) do
  subject { described_class.new initialize_child_argument, max }

  let(:initialize_child_argument) { BehaviorTree.const_get(:NodeBase).new }
  let(:max) { 1 }

  describe '.initialize' do
    context 'argument has incorrect type' do
      let(:max) { 0 }

      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'argument has correct type' do
      it { expect { subject }.not_to raise_error }
    end
  end

  describe '.repeat_while' do
    it { expect { subject.send :repeat_while }.to raise_error NotImplementedError }
  end
end
