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

  describe '.set' do
    let(:value) { described_class::SUCCESS }
    it 'changes the value' do
      expect(subject.success?).to be true
      subject.set described_class::FAILURE
      expect(subject.failure?).to be true
    end
  end
end
