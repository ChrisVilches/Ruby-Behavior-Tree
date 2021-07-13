# frozen_string_literal: true

module BehaviorTree
  module TreeStructure
    # Basic tree algorithms.
    module Algorithms
      TRAVERSAL_ORDERS = %i[preorder postorder].freeze

      def repeated_nodes
        visited = Set.new
        repeated_nodes = Set.new

        dfs = ->(node) {
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

        dfs = ->(node) {
          break true if current_path.include?(node)

          current_path << node
          result = node.children.any?(&dfs)
          current_path.delete node

          result
        }

        dfs.call(chainable_node)
      end

      def each_node(order_type = TRAVERSAL_ORDERS.first, &block)
        return enum_for(:each_node, order_type) unless block_given?

        raise ArgumentError, "Traversal order must be in: #{TRAVERSAL_ORDERS}" unless TRAVERSAL_ORDERS.any?(order_type)

        Enumerator.new do |y|
          idx = 0
          visit = ->(node, depth) {
            y.yield(node, depth, idx)
            idx += 1
          }

          dfs = ->(node, depth) {
            visit.(node, depth) if order_type == :preorder
            node.children.each { |child| dfs.call(child, depth + 1) }
            visit.(node, depth) if order_type == :postorder
          }

          dfs.call(chainable_node, 0)
        end.each(&block)
      end
    end
  end
end
