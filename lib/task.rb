# frozen_string_literal: true

require_relative './node'

module BehaviorTree
  # A task (leaf) node.
  class Task < Node
    # TODO: If this class doesn't add any value (add methods, etc)
    #       then remove it and make all tasks inherit from Node.
    #       But naming it "Task" would actually make it easier for programmers
    #       (users) to understand what's being done.
  end
end
