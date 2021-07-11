# frozen_string_literal: true

require_relative '../node_base'

module BehaviorTree
  # A node that has children (abstract class).
  class ControlNodeBase < NodeBase
    include NodeIterators::PrioritizeNonSuccess
    include NodeIterators::AllNodes

    DEFAULT_CHILDREN_TRAVERSAL_STRATEGY = :prioritize_non_success

    def initialize(children = [], traversal_strategy: DEFAULT_CHILDREN_TRAVERSAL_STRATEGY)
      unless respond_to?(traversal_strategy)
        err = "Iteration strategy named '#{traversal_strategy}' does not exist."
        raise NoMethodError, err
      end

      super()
      @children = children
      @strategy = traversal_strategy
    end

    def <<(child)
      @children << child
      @children.flatten! # Accepts array of children too.
    end

    def halt!
      validate_non_leaf!

      super

      @children.each(&:halt!)
    end

    protected

    def validate_non_leaf!
      raise InvalidLeafNodeError if @children.empty?
    end

    def tick_each_children(&block)
      validate_non_leaf!
      return enum_for(:tick_each_children) unless block_given?

      Enumerator.new do |y|
        enum = send(@strategy)
        validate_enum!(enum)

        enum.each do |child|
          child.tick!
          y << child
        end
      end.each(&block)
    end

    # Keep it simple, because it's executed everytime it ticks.
    def validate_enum!(enum)
      raise IncorrectTraversalStrategyError, enum unless enum.respond_to? :each
    end
  end

  private_constant :ControlNodeBase
end
