# frozen_string_literal: true

module BehaviorTree
  module Decorators
    # Base class for a decorator node.
    class DecoratorBase < Node
      attr_reader :child

      def initialize(child_)
        super()
        self.child = child_
      end

      def child=(child)
        validate_child!(child)
        @child = child
      end

      def tick!
        # TODO: Add error for when child is nil.
        child.tick!
        decorate
      end

      protected

      def decorate
        raise NotImplementedError
      end

      private

      def validate_child!(child)
        return if child.is_a?(Node)

        raise ArgumentError, "Decorator can only have a #{Node.name} object as a child. Attempted to assign #{child}."
      end
    end

    private_constant :DecoratorBase
  end
end
