# frozen_string_literal: true

require_relative './branch_node'

module BehaviorTree
  # A sequence node.
  class Sequence < BranchNode
    def tick!
      super

      resume_tick_each_children do |child|
        one_failed if child.failure?
        one_running if child.running?
        return nil unless child.success?
      end

      halt!
    end

    def one_running
      status.running!
    end

    def one_failed
      halt!
      status.failure!
    end
  end
end
