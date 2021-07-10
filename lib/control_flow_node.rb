# frozen_string_literal: true

require_relative './node'

module BehaviorTree
  # A node that has children (abstract class).
  class ControlFlowNode < Node
    include NodeIterators::PrioritizeNonSuccess

    def initialize(children = [])
      super()
      @children = children
    end

    def <<(child)
      @children << child
    end

    def halt!
      super
      @children.each(&:halt!)
    end

    def tick_child(child, &block)
      child.tick!
      block&.call(child)
      child.status
    end

    def tick_each_children(children = @children, &block)
      return children.each unless block_given?

      children.map do |child|
        child.tick!
        block&.call(child)
        child.status
      end
    end
  end

  # TODO: Set as private. Can be done but Rspec fails.
  # private_constant :ControlFlowNode
end
