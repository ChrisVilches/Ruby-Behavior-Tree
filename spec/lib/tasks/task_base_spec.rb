# frozen_string_literal: true

describe BehaviorTree::TaskBase do
  let(:context) { { a: 1 } }
  let(:sum_task) do
    described_class.new do
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

  # NOTE: Probably needs to be removed, since a task can have its behavior implemented
  #       by overloading the method rather than passing a block, so checking whether it
  #       does not have a block doesn't guarantee the behavior is empty.
  # describe '.void?' do
  #   context 'has block' do
  #     it { expect(described_class.new { :empty_block }.void?).to be false }
  #   end

  #   context 'does not have block' do
  #     it { expect(described_class.new.void?).to be true }
  #   end
  # end
end
