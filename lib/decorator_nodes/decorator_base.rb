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

        # TODO: When is halt! executed in a decorator?
        #       Note that removing this whole method, does trigger some errors in RSpec.
        #
        #       And since halt! sets status to success, isn't it a bit dangerous (or confusing, rather)
        #       to execute status_map?
        #
        #       Create specs for this.
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
