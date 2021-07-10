# frozen_string_literal: true

require_relative './node'

module BehaviorTree
  # A task (leaf) node.
  class Task < Node
    def tick!
      status.running!
    end

    def halt!
      status.success!
    end
  end
end
