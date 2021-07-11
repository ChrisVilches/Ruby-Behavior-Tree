# frozen_string_literal: true

# TODO: Should errors be private and scoped to the class that raises them?
module BehaviorTree
  # Exception for when the children traversal strategy is incorrect.
  class IncorrectTraversalStrategyError < StandardError
    def initialize(value)
      err = [
        "Strategy for iterating children nodes must return an object which has an 'each' method.",
        "Attempted to use strategy: #{value}."
      ]
      super err.join ' '
    end
  end

  # Exception for control flow nodes without children.
  class InvalidLeafNodeError < StandardError
    def initialize
      super 'This node cannot be a leaf node. Insert children before ticking.'
    end
  end

  # Exception for when a node has an incorrect status value.
  class IncorrectStatusValueError < StandardError
    def initialize(value)
      super "Incorrect status value. A node cannot have '#{value}' status."
    end
  end
end
