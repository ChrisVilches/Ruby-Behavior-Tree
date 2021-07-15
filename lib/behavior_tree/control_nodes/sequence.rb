# frozen_string_literal: true

module BehaviorTree
  # A sequence node.
  class Sequence < ControlNodeBase
    def on_tick
      tick_each_children do |child|
        return status.running! if child.status.running?

        if child.status.failure?
          halt!

          # Halt, but set success only to children, not to self.
          # Self status must be overriden to failure.
          status.failure!
          return
        end
      end

      # Both self and children have the status set to success.
      halt!
    end
  end
end
