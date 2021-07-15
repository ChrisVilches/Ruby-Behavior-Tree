# frozen_string_literal: true

module BehaviorTree
  # Root node of the tree.
  # This is the class that must be instantiated by the user.
  class Tree < SingleChildNodeBase
    include TreeStructure::Algorithms
    include TreeStructure::Printer
    attr_reader :context

    CHILD_VALID_CLASSES = [
      Decorators::DecoratorBase, ControlNodeBase, TaskBase
    ].freeze

    def initialize(child)
      super(child) if child.nil? # Cannot be leaf, raise error.

      if CHILD_VALID_CLASSES.any? { |node_class| child.is_a?(NodeBase) && child.chainable_node.is_a?(node_class) }
        super(child)
        return
      end

      raise InvalidTreeMainNodeError, child.class
    end

    def chainable_node
      @child
    end

    def ensure_after_tick
      # Copy the main node status to self.
      self.status = child.status
    end
  end
end
