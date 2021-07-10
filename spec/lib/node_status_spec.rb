# frozen_string_literal: true

describe BehaviorTree::NodeStatus do
  subject { described_class.new value }
  context 'success' do
    let(:value) { BehaviorTree::NodeStatus::SUCCESS }
    it { expect(subject.success?).to be true }
  end
  context 'running' do
    let(:value) { BehaviorTree::NodeStatus::RUNNING }
    it { expect(subject.running?).to be true }
  end
  context 'failure' do
    let(:value) { BehaviorTree::NodeStatus::FAILURE }
    it { expect(subject.failure?).to be true }
  end
  context 'incorrect value' do
    let(:value) { :incorrect_value }
    it { expect { subject }.to raise_error BehaviorTree::IncorrectStatusValue }
  end

  describe '.set' do
    let(:value) { BehaviorTree::NodeStatus::SUCCESS }
    it 'changes the value' do
      expect(subject.success?).to be true
      subject.set BehaviorTree::NodeStatus::FAILURE
      expect(subject.failure?).to be true
    end
  end
end
