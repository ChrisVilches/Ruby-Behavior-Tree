# frozen_string_literal: true

require_relative './node'

module BehaviorTree
  # A node that has children (abstract class).
  class ControlFlowNode < Node
    include NodeIterators::PrioritizeNonSuccess
    include NodeIterators::AllNodes

    DEFAULT_CHILDREN_EXECUTION_STRATEGY = :prioritize_non_success

    def initialize(children = [], strategy: DEFAULT_CHILDREN_EXECUTION_STRATEGY)
      raise NoMethodError, "No node iteration strategy named '#{strategy}'." unless respond_to?(strategy)

      super()
      @children = children
      @strategy = strategy
    end

    def <<(child)
      @children << child
      @children.flatten! # Accepts array of children too.
    end

    def halt!
      super
      @children.each(&:halt!)
    end

    protected

    def tick_each_children(&block)
      return enum_for(:tick_each_children) unless block_given?

      Enumerator.new do |y|
        send(@strategy).each do |child|
          child.tick!
          y << child
        end
      end.each(&block)
    end
  end

  # TODO: Set as private. Can be done but Rspec fails.
  # private_constant :ControlFlowNode
end
