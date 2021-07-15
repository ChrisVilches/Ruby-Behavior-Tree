# frozen_string_literal: true

module BehaviorTree
  module Decorators
    # Returns always success when the child is not running.
    class ForceSuccess < DecoratorBase
      protected

      def status_map
        return status.running! if child.status.running?

        status.success!
      end
    end
  end
end
