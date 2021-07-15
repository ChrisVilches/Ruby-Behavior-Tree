# frozen_string_literal: true

describe BehaviorTree::Decorators.const_get(:DecoratorBase) do
  subject { described_class.new child }

  let(:child) { BehaviorTree.const_get(:NodeBase).new }

  describe '.initialize' do
    context 'argument has incorrect type' do
      let(:child) { [1, 2, 3] }

      it { expect { subject }.to raise_error TypeError }
    end

    context 'argument has correct type' do
      it { expect { subject }.not_to raise_error }
    end
  end

  describe '.tick!' do
    before { subject.tick! }

    it { is_expected.to have_children_ticked_times [1] }
  end
end
