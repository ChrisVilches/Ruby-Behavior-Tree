# frozen_string_literal: true

module BehaviorTree
  # A sequence node.
  class Sequence < ControlFlowNode
    def tick!
      super

      tick_each_children do |child|
        return status.running! if child.status.running?
        return status.failure! if child.status.failure?
      end

      halt!
      status.success!
    end
  end
end
