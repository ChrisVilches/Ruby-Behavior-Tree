# frozen_string_literal: true

module TestControlNodes
  class Shuffle < BehaviorTree::Sequence
    children_traversal_strategy :shuffle

    private

    # Memoize shuffled order. Keep the same order while the sequence is running.
    def shuffle
      @shuffled_order ||= @children.shuffle
      running_idx = @shuffled_order.find_index { |node| node.status.running? }.to_i

      @shuffled_order[running_idx..]
    end

    # Un-memoize the shuffled order so that it's shuffled again (everytime the status goes from
    # not-running to running).
    def on_started_running
      @shuffled_order = nil
    end
  end
end

describe TestControlNodes::Shuffle do
  subject { shuffle_sequence }

  let(:shuffle_sequence) { described_class.new }
  let(:nops) { (1..20).map { BehaviorTree::Nop.new 2 } }

  before { shuffle_sequence << nops }

  context 'ticked 0 times' do
    it { is_expected.to be_success }
    it { is_expected.to have_children_ticked_times [0] * 20 }
  end

  # There are 20 NOPs, each taking 2 ticks to complete, thus the entire sequence takes 21 ticks.
  #
  # While it's running, we store the cached shuffled order, and compare it a few times with the
  # current shuffled order that's being used.
  #
  # After the sequence ends, we tick again to set it to run again, and check the shuffled order changes.
  context 'ticked many times' do
    it do
      current_shuffled_order = -> { subject.instance_variable_get(:@shuffled_order) }

      subject.tick!
      expect(subject).to be_running

      cached_order = current_shuffled_order.()
      10.times { subject.tick! } # Total of 11 ticks (running)
      expect(cached_order).to eq current_shuffled_order.()
      expect(subject).to be_running

      10.times { subject.tick! } # Total of 21 ticks (just completed, success)
      expect(cached_order).to eq current_shuffled_order.()
      expect(subject).to be_success

      subject.tick! # Change status from 'success' to 'running'
      expect(cached_order).not_to eq current_shuffled_order.()
      expect(subject).to be_running
    end
  end
end
