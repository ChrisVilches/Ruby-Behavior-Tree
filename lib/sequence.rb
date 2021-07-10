# frozen_string_literal: true

require_relative './branch_node'

module BehaviorTree
  # A sequence node.
  class Sequence < BranchNode
    def tick!
      super

      statuses = resume_tick_each_children do |child|
        if child.status.failure?
          status.failure!
          return nil
        end

        child.status
      end

      halt! if statuses.all?(&:success?)
    end
  end
end
