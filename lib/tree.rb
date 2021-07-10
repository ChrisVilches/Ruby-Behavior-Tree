# frozen_string_literal: true

module BehaviorTree
  # Root node of the tree.
  # This is the class that must be instantiated by the user.
  class Tree < ControlFlowNode
    def initialize
      # Implementation should be:
      # Has tick! method
      # Can have task or branch (control flow) children.
      #   -> If it's a task child, then it may be only one. The root doesn't have the logic
      #      to execute multiple tasks (there has to be a control flow node that handles that)
      #
      # Maybe some method to debug/validate tree structure.
      # Regarding the point about tasks only being able to have one, actually this applies for
      # control-flow nodes as well. Because if there are many control-flow nodes, we don't know
      # how to execute them (in which order, etc).
      #
      # So to summarize: Only one child. This means, remove the "< ControlFlowNode" (inheritance),
      # as the root is NOT a control-flow node.
      #
      # But can it really have task children? How does it execute them and handle the return value?
      # it should just get the same value as the task? yeah that sounds good.
      #
      # Also needs an operation to be appended as a branch into another tree's node. Basically just
      # needs to be flattened.
    end
  end
end
