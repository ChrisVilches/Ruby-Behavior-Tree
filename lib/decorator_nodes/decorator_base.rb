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
        raise InvalidLeafNodeError if child.nil?

        child.tick!
        decorate
        status_map
      end

      def halt!
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
        raise NotImplementedError
      end

      private

      def validate_child!(child)
        return if child.is_a?(Node)

        raise ArgumentError, "Decorator can only have a #{Node.name} object as a child. Attempted to assign #{child.class}."
      end
    end

    private_constant :DecoratorBase
  end
end
