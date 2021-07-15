# frozen_string_literal: true

describe BehaviorTree::Builder do
  describe '.build_random_tree' do
    subject { described_class.build_random_tree(recursion_amount: recursion_amount) }
    context 'has negative recursion amount' do
      let(:recursion_amount) { -2 }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
    context 'has 0 recursion amount' do
      let(:recursion_amount) { 0 }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
    context 'has 10 recursion amount' do
      let(:recursion_amount) { 10 }
      it { is_expected.to be_instance_of(BehaviorTree::Tree) }
      it { expect(subject.size > 50).to be true } # I can't predict the exact number.
    end
    context '200 random trees are created' do
      it 'does not crash' do
        expect { 200.times { described_class.build_random_tree } }.not_to raise_error
      end
    end
    context 'ticked 1000 times' do
      let(:recursion_amount) { 10 }
      it 'does not crash' do
        expect { 200.times { subject.tick! } }.to_not raise_error
      end
    end
  end
end
