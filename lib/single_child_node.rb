# frozen_string_literal: true

module BehaviorTree
  # A node that has a single child (abstract class).
  class SingleChildNodeBase < NodeBase
    attr_reader :child

    def initialize(child)
      super()
      self.child = child
    end

    def child=(child)
      validate_child!(child)
      @child = child
    end

    def tick!
      raise InvalidLeafNodeError if @child.nil?

      super
    end

    def halt!
      raise InvalidLeafNodeError if @child.nil?

      super
    end

    private

    def validate_child!(child)
      return if child.is_a?(NodeBase)

      err = "Decorator can only have a #{NodeBase.name} object as a child. Attempted to assign #{child.class}."
      raise ArgumentError, err
    end
  end

  private_constant :SingleChildNodeBase
end
