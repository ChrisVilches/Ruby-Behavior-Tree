# frozen_string_literal: true

module TestNodes
  class CustomCondition < BehaviorTree::Decorators::Condition
    def should_tick?
      context[:a] > -1
    end
  end

  class AlwaysEvalTo < BehaviorTree::Decorators::Condition
    def initialize(child, value)
      super(child)
      @value = value
    end

    def should_tick?
      @value
    end
  end

  class DecreaserTask < BehaviorTree::Task
    def on_tick
      context[:a] -= 1
      status.success!
    end
  end
end

describe TestNodes::CustomCondition do
  subject { described_class.new task }

  before { subject.context = { a: 1 } }

  let(:task) { TestNodes::DecreaserTask.new }

  describe '.initialize' do
    it { expect { subject }.not_to raise_error }
  end

  describe '.tick' do
    context 'ticked 1 times' do
      before { subject.tick! }

      it { is_expected.to be_success }
      it { expect(subject.tick_count).to eq 1 }
      it { is_expected.to have_children_ticked_times [1] }
      it { expect(subject.send(:context)).to eq({ a: 0 }) }
      it { expect(subject.instance_variable_get(:@tick_prevented)).to be false }
    end

    context 'ticked 2 times' do
      before { 2.times { subject.tick! } }

      it { is_expected.to be_success }
      it { expect(subject.tick_count).to eq 2 }
      it { is_expected.to have_children_ticked_times [2] }

      it 'is decreased after fulfilling the condition' do
        expect(subject.send(:context)).to eq({ a: -1 })
      end

      it { expect(subject.instance_variable_get(:@tick_prevented)).to be false }
    end

    context 'ticked 3 times' do
      before { 3.times { subject.tick! } }

      it { is_expected.to be_failure }
      it { expect(subject.tick_count).to eq 3 }
      it { is_expected.to have_children_ticked_times [2] }
      it { expect(subject.send(:context)).to eq({ a: -1 }) }
      it { expect(subject.instance_variable_get(:@tick_prevented)).to be true }
    end

    context 'ticked 4 times' do
      before { 4.times { subject.tick! } }

      it { is_expected.to be_failure }
      it { expect(subject.tick_count).to eq 4 }
      it { is_expected.to have_children_ticked_times [2] }
      it { expect(subject.send(:context)).to eq({ a: -1 }) }
      it { expect(subject.instance_variable_get(:@tick_prevented)).to be true }
    end
  end
end

# Condition classes with a constructor argument.
describe TestNodes::AlwaysEvalTo do
  subject { described_class.new task, value }

  let(:task) { TestNodes::DecreaserTask.new }

  before { subject.context = { a: 5 } }

  describe '.initialize' do
    let(:value) { true }

    it { expect { subject }.not_to raise_error }
  end

  describe '.tick' do
    before { subject.tick! }

    context 'value is true' do
      let(:value) { true }

      it { is_expected.to be_success }
      it { is_expected.to have_children_ticked_times [1] }
    end

    context 'value is false' do
      let(:value) { false }

      it { is_expected.to be_failure }
      it { is_expected.to have_children_ticked_times [0] }
    end
  end
end
