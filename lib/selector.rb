# frozen_string_literal: true

require_relative './control_flow_node'

module BehaviorTree
  # A selector node.
  class Selector < ControlFlowNode
    def tick!
      super

      resume_tick_each_children do |child|
        # A bit verbose, but helps understand what happens in each case.
        if child.status.success?
          halt!
          return status.success!
        end

        return status.running! if child.status.running?
        next if child.status.failure?
      end

      status.failure!
    end
  end
end
