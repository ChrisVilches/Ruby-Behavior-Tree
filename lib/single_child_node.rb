# frozen_string_literal: true

module BehaviorTree
  # A node that has a single child (abstract class).
  class SingleChildNodeBase < NodeBase
    attr_reader :child

    def initialize(child)
      validate_child! child
      super()
      @child = child
    end

    def tick!
      super
      @child.tick!
    end

    def halt!
      super
      @child.halt!
    end

    private

    def validate_child!(child)
      raise InvalidLeafNodeError if child.nil?
      return if child.is_a?(NodeBase)

      err = "Decorator can only have a #{NodeBase.name} object as a child. Attempted to assign #{child.class}."
      raise ArgumentError, err
    end
  end

  private_constant :SingleChildNodeBase
end
