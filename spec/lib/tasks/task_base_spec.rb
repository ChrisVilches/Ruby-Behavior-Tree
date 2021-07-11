# frozen_string_literal: true

describe BehaviorTree::TaskBase do
  let(:context) { { a: 1 } }
  let(:sum_task) do
    described_class.new do |context, status|
      context[:a] += 1
      status.success!
    end
  end

  before do
    sum_task.context = context
  end

  subject { sum_task }

  describe '.tick!' do
    before { 3.times { subject.tick! } }
    it { is_expected.to be_success }
    it { expect(subject.instance_variable_get(:@context)[:a]).to eq 4 }
  end
end
