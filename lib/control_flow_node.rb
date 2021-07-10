# frozen_string_literal: true

require_relative './node'

module BehaviorTree
  # A node that has children (abstract class).
  class ControlFlowNode < Node
    def initialize(children = [])
      super()
      @children = children
    end

    def tick!
      status.running!
    end

    def <<(child)
      @children << child
    end

    def halt!
      status.success!
      @children.each(&:halt!)
    end

    def tick_each_children(children = @children, &block)
      children.map do |child|
        child.tick!
        block&.call(child)
        child.status
      end
    end

    # If there's at least one node without 'success' status, then continue from there, in order.
    # Else, tick all nodes.
    # TODO: There should be more ways to get the nodes that should be iterated, not just this way.
    #       In fact, every selector should implement their own, because there can be many types
    #       of selectors, with different logic to restart, try again, etc.
    #       Restructure in a way that these can be used in a more flexible way.
    #       My idea: create a mixin that can be included in the control-flow nodes, this way
    #       there can be many pre-fab tick-iterators that can be reused in many control-flow nodes,
    #       including those created by the user.
    #
    #       An elegant way to do it would be to return an enumerator, so it's more similar to other
    #       things like 'each', 'times', 'map' (when used without a block. When used with a block
    #       it should return something as well, but different).
    #
    #       Another way would be to return the ones that were actually ticked, that would be helpful
    #       for testing.
    def resume_tick_each_children(&block)
      index_running = @children.find_index { |node| !node.status.success? }
      filtered_children = @children[index_running..] # If index is nil, returns entire array.
      tick_each_children filtered_children, &block
    end
  end

  # TODO: Set as private. Can be done but Rspec fails.
  # private_constant :ControlFlowNode
end
