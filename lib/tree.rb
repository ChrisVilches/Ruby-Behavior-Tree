# frozen_string_literal: true

module BehaviorTree
  # Root node of the tree.
  # This is the class that must be instantiated by the user.
  class Tree < SingleChildNodeBase
    CHILD_VALID_CLASSES = [
      Decorators::DecoratorBase, ControlNodeBase, TaskBase
    ].freeze

    def initialize(child)
      super(child)

      return if CHILD_VALID_CLASSES.any? { |node_class| child.chainable_node.is_a?(node_class) }

      raise InvalidTreeMainNodeError, child.chainable_node.class
    end

    def chainable_node
      @child
    end

    def ensure_after_tick
      # Copy the main node status to self.
      self.status = child.status
    end

    def validate_tree!
      raise NotImplementedError
    end
  end
end
