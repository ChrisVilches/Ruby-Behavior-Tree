# frozen_string_literal: true

require_relative './node'

module BehaviorTree
  # A task (leaf) node.
  class Task < Node
    def tick!
      status.running!

      # TODO: Only task nodes increase this?
      #       (At the moment, this is only used in tests, and all nodes tested are tasks.)
      @tick_count += 1
    end

    def halt!
      status.success!
    end
  end
end
