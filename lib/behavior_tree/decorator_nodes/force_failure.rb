# frozen_string_literal: true

module BehaviorTree
  module Decorators
    # Returns always failure when the child is not running.
    class ForceFailure < DecoratorBase
      def display_name
        'forcefailure'
      end

      protected

      def status_map
        return status.running! if child.status.running?

        status.failure!
      end
    end
  end
end
