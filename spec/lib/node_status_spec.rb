# frozen_string_literal: true

describe BehaviorTree.const_get(:NodeStatus) do
  subject { described_class.new value }

  context 'success' do
    let(:value) { described_class::SUCCESS }

    it { expect(subject.success?).to be true }
  end

  context 'running' do
    let(:value) { described_class::RUNNING }

    it { expect(subject.running?).to be true }
  end

  context 'failure' do
    let(:value) { described_class::FAILURE }

    it { expect(subject.failure?).to be true }
  end

  context 'incorrect value' do
    let(:value) { :incorrect_value }

    it { expect { subject }.to raise_error BehaviorTree::IncorrectStatusValueError }
  end

  describe '==' do
    it { expect(described_class.new(described_class::FAILURE)).to eq described_class.new(described_class::FAILURE) }
    it { expect(described_class.new(described_class::FAILURE)).not_to eq described_class.new(described_class::RUNNING) }
    it { expect(described_class.new(described_class::FAILURE)).not_to eq described_class.new(described_class::SUCCESS) }
  end

  describe '.set' do
    let(:value) { described_class::SUCCESS }

    it 'changes the value' do
      expect(subject.success?).to be true
      subject.set described_class::FAILURE
      expect(subject.failure?).to be true
    end
  end
end
