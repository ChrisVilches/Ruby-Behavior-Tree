# frozen_string_literal: true

module TestControlNodes
  class Shuffle < BehaviorTree::Selector
    children_traversal_strategy :shuffle

    private

    # Memoize shuffled order. Keep the same order while the selector is running.
    def shuffle
      @shuffle ||= @children.shuffle
    end

    # Un-memoize the shuffled order so that it's shuffled again (everytime the status goes from
    # not-running to running).
    def on_started_running
      @shuffle = nil
    end
  end
end

describe TestControlNodes::Shuffle do
  pending 'Make a custom control node for shuffling and memoizing the order until next running! state set.'
  pending 'shuffle order is the same while it is running'
  pending 'shuffle order changes when the node re-enters running state (coming from not-running)'
end
