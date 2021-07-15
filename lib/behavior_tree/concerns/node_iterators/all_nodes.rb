# frozen_string_literal: true

module BehaviorTree
  module NodeIterators
    # Iterates all nodes, without skipping or re-ordering.
    module AllNodes
      def all_nodes
        @children.each
      end
    end
  end
end
