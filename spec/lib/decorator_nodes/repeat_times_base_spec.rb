# frozen_string_literal: true

describe BehaviorTree::Decorators.const_get(:RepeatTimesBase) do
  let(:initialize_child_argument) { BehaviorTree.const_get(:Node).new }
  let(:max) { 1 }
  subject { described_class.new initialize_child_argument, max }

  describe '.initialize' do
    context 'argument has incorrect type' do
      let(:max) { 0 }
      it { expect { subject }.to raise_error ArgumentError }
    end

    context 'argument has correct type' do
      it { expect { subject }.to_not raise_error }
    end
  end
end
