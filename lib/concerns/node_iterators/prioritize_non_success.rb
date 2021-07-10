# frozen_string_literal: true

module BehaviorTree
  module NodeIterators
    # Strategy for iterating children nodes where it starts from the non-success nodes.
    # If no non-success node exists, it iterates all nodes.
    module PrioritizeNonSuccess
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

        return filtered_children.each { |child| tick_child(child) } unless block_given?

        tick_each_children filtered_children, &block
      end
    end
  end
end
