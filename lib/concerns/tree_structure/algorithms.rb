# frozen_string_literal: true

module BehaviorTree
  module TreeStructure
    # Basic tree algorithms.
    module Algorithms
      def repeated_nodes
        visited = Set.new
        repeated_nodes = Set.new

        dfs = lambda { |node|
          break repeated_nodes << node if visited.include?(node)

          visited << node

          node.children.each(&dfs)
        }

        dfs.call(chainable_node)

        repeated_nodes
      end

      def uniq_nodes?
        repeated_nodes.empty?
      end

      # TODO: Should skip visited nodes too? It seems it's unnecessary.
      def cycle?
        current_path = Set.new

        dfs = lambda { |node|
          break true if current_path.include?(node)

          current_path << node
          result = node.children.any?(&dfs)
          current_path.delete node

          result
        }

        dfs.call(chainable_node)
      end
    end
  end
end
