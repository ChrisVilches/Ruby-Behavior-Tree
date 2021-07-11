# frozen_string_literal: true

module BehaviorTree
  # Root node of the tree.
  # This is the class that must be instantiated by the user.
  class Tree
    def initialize(child)
      @child = child
    end

    def tick!
    end

    def validate_tree!
    end
  end
end
