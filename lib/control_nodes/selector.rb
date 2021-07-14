# frozen_string_literal: true

require_relative './control_node_base'

module BehaviorTree
  # A selector node.
  class Selector < ControlNodeBase
    def on_tick
      tick_each_children do |child|
        return status.running! if child.status.running?

        # Both self and children have the status set to success.
        return halt! if child.status.success?
      end

      # Halt, but set success only to children, not to self.
      # Self status must be overriden to failure.
      halt!
      status.failure!
    end
  end
end
