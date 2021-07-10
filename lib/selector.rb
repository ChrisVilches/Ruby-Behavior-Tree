# frozen_string_literal: true

require_relative './branch_node'

module BehaviorTree
  # A selector node.
  class Selector < BranchNode
    def tick!
      super

      resume_tick_each_children do |child|
        if child.status.success?
          halt!
          return nil
        end
      end
    end
  end
end
