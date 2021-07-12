# frozen_string_literal: true

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

  # Exception raised when the main node of a tree is of invalid type.
  class InvalidTreeMainNodeError < StandardError
    def initialize(node_type)
      super "Main node of a tree cannot be of type #{node_type}. Valid types are: #{Tree::CHILD_VALID_CLASSES}"
    end
  end

  # Exception for control nodes without children.
  class InvalidLeafNodeError < StandardError
    def initialize
      super 'This node cannot be a leaf node.'
    end
  end

  # Exception for when a node has an incorrect status value.
  class IncorrectStatusValueError < StandardError
    def initialize(value)
      super "Incorrect status value. A node cannot have '#{value}' status."
    end
  end

  # Exception for incorrect node type when using the DSL builder.
  class NodeTypeDoesNotExistError < StandardError
    def initialize(missing_method, suggestion, method_alias)
      suggestion = suggestion.to_s
      method_alias = method_alias.to_s

      err = ["Node type '#{missing_method}' does not exist."]
      unless suggestion.empty?
        alias_text = method_alias.empty? ? '' : " (alias of #{method_alias})"
        err << "Did you mean '#{suggestion}'#{alias_text}?"
      end

      super err.join ' '
    end
  end

  # Exception for misuse of the DSL builder.
  class DSLStandardError < StandardError
    def initialize(message)
      super "Cannot build tree (DSL Builder): #{message}"
    end
  end

  # Exception for when trying to register a DSL keyword that already exists.
  class RegisterDSLNodeAlreadyExistsError < StandardError
    def initialize(node_type)
      super "Cannot register node '#{node_type}', it already exists."
    end
  end
end
