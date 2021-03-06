# frozen_string_literal: true

require_relative '../single_child_node'

module BehaviorTree
  module Decorators
    # Base class for a decorator node.
    class DecoratorBase < SingleChildNodeBase
      def on_tick
        super
        decorate
      end

      def ensure_after_tick
        status_map
      end

      def halt!
        super

        status_map
      end

      protected

      # Decorate behavior. Retry, repeat, etc.
      # Leave empty if there's no extra behavior to add.
      # Default behavior is to do nothing additional.
      # @return [void]
      def decorate; end

      # This method must change the self node status in function
      # of the child status. The default behavior is to copy its status.
      # @return [void]
      def status_map
        self.status = child.status
      end
    end
  end
end
