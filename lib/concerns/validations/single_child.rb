# frozen_string_literal: true

module BehaviorTree
  module Validations
    # Validates that a node has a single node child.
    module SingleChild
      private

      def validate_single_child!(child)
        raise InvalidLeafNodeError if child.nil?
        return if child.is_a?(NodeBase)

        err = "Decorator can only have a #{NodeBase.name} object as a child. Attempted to assign #{child.class}."
        raise ArgumentError, err
      end
    end
  end
end
