# frozen_string_literal: true

require_relative './control_flow_node'

module BehaviorTree
  # A sequence node.
  class Sequence < ControlFlowNode
    def tick!
      super

      resume_tick_each_children do |child|
        return status.running! if child.status.running?
        return status.failure! if child.status.failure?
      end

      halt!
      status.success!
    end
  end
end
