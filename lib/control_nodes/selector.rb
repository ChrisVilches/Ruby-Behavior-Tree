# frozen_string_literal: true

module BehaviorTree
  # A selector node.
  class Selector < ControlNodeBase
    def tick!
      super

      tick_each_children do |child|
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
