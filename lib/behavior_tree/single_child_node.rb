# frozen_string_literal: true

module BehaviorTree
  # A node that has a single child (abstract class).
  class SingleChildNodeBase < NodeBase
    include Validations::SingleChild
    attr_reader :child

    def initialize(child)
      validate_single_child! child
      super()
      @child = child.chainable_node
    end

    def on_tick
      @child.tick!
    end

    def halt!
      super
      @child.halt!
    end
  end

  private_constant :SingleChildNodeBase
end
