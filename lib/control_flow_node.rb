# frozen_string_literal: true

require_relative './node'

module BehaviorTree
  # A node that has children (abstract class).
  class ControlFlowNode < Node
    include NodeIterators::PrioritizeNonSuccess
    include NodeIterators::AllNodes

    DEFAULT_CHILDREN_TRAVERSAL_STRATEGY = :prioritize_non_success

    def initialize(children = [], traversal_strategy: DEFAULT_CHILDREN_TRAVERSAL_STRATEGY)
      raise NoMethodError, "Iteration strategy named '#{traversal_strategy}' does not exist." unless respond_to?(traversal_strategy)

      super()
      @children = children
      @strategy = traversal_strategy
    end

    def <<(child)
      @children << child
      @children.flatten! # Accepts array of children too.
    end

    def halt!
      raise InvalidLeafNodeError if @children.empty?

      super

      @children.each(&:halt!)
    end

    protected

    def tick_each_children(&block)
      raise InvalidLeafNodeError if @children.empty?
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

  private_constant :ControlFlowNode
end
