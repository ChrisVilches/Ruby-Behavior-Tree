# frozen_string_literal: true

module TestNodes
  class CustomTask < BehaviorTree::Task
    def on_tick
      context[:a] += 1
      context[:a].even? ? status.success! : status.running!
    end
  end

  class CustomTaskWithConstructorArgument < BehaviorTree::Task
    def initialize(inc)
      super()
      @inc = inc
    end

    def on_tick
      context[:a] += @inc
      context[:a].even? ? status.success! : status.running!
    end
  end
end

describe TestNodes::CustomTask do
  subject { described_class.new }

  let(:initial_context) { { a: 0 } }

  before { subject.context = initial_context }

  context 'ticked 0 times' do
    it { is_expected.to be_success }
    it { expect(subject.send(:context)).to eq({ a: 0 }) }
  end

  context 'ticked 1 times' do
    before { subject.tick! }

    it { is_expected.to be_running }
    it { expect(subject.send(:context)).to eq({ a: 1 }) }
  end

  context 'ticked 2 times' do
    before { 2.times { subject.tick! } }

    it { is_expected.to be_success }
    it { expect(subject.send(:context)).to eq({ a: 2 }) }
  end

  context 'ticked 3 times' do
    before { 3.times { subject.tick! } }

    it { is_expected.to be_running }
    it { expect(subject.send(:context)).to eq({ a: 3 }) }
  end
end

describe TestNodes::CustomTaskWithConstructorArgument do
  subject { described_class.new(3) }

  let(:initial_context) { { a: 0 } }

  before { subject.context = initial_context }

  context 'ticked 0 times' do
    it { is_expected.to be_success }
    it { expect(subject.send(:context)).to eq({ a: 0 }) }
  end

  context 'ticked 1 times' do
    before { subject.tick! }

    it { is_expected.to be_running }
    it { expect(subject.send(:context)).to eq({ a: 3 }) }
  end

  context 'ticked 2 times' do
    before { 2.times { subject.tick! } }

    it { is_expected.to be_success }
    it { expect(subject.send(:context)).to eq({ a: 6 }) }
  end

  context 'ticked 3 times' do
    before { 3.times { subject.tick! } }

    it { is_expected.to be_running }
    it { expect(subject.send(:context)).to eq({ a: 9 }) }
  end
end
