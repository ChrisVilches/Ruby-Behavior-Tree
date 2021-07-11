# frozen_string_literal: true

require_relative '../single_child_node'

module BehaviorTree
  module Decorators
    # Base class for a decorator node.
    class DecoratorBase < SingleChildNodeBase
      def tick!
        super

        unless should_tick?
          status.failure!
          return
        end

        child.tick!
        decorate
        status_map
      end

      def halt!
        super

        @child.halt!
        status_map
      end

      protected

      # TODO: Comment
      def decorate
        raise NotImplementedError
      end

      # TODO: Comment
      def status_map
        self.status = child.status
      end

      def should_tick?
        true
      end
    end

    private_constant :DecoratorBase
  end
end
