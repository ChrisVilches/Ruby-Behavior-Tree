# frozen_string_literal: true

module BehaviorTree
  module TreeStructure
    # Basic tree algorithms.
    module Algorithms
      TRAVERSAL_ORDERS = %i[depth_postorder depth_preorder breadth].freeze

      def repeated_nodes
        visited = Set.new
        repeated_nodes = Set.new

        dfs = ->(node) {
          break repeated_nodes << node if visited.include?(node)

          visited << node

          node.children.each(&dfs)
        }

        dfs.(chainable_node)

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

        dfs.(chainable_node)
      end

      def each_node(order_type = TRAVERSAL_ORDERS.first, &block)
        return enum_for(:each_node, order_type) unless block_given?

        raise ArgumentError, "Traversal order must be in: #{TRAVERSAL_ORDERS}" unless TRAVERSAL_ORDERS.any?(order_type)

        enum_for("#{order_type}_yielder").each(&block)
      end

      private

      def breadth_node_yielder
        queue = [[chainable_node, 0]]
        idx = 0
        depth = 0
        until queue.empty?
          node, depth = queue.shift # Remove first
          queue.concat(node.children.map { |child| [child, depth + 1] }) # Enqueue node with depth.
          yield(node, depth, idx)
          idx += 1
        end
        nil
      end

      def depth_postorder_node_yielder
        idx = 0

        dfs = ->(node, depth) {
          node.children.each { |child| dfs.(child, depth + 1) }
          yield(node, depth, idx)
          idx += 1
        }

        dfs.(chainable_node, 0)
        nil
      end

      def depth_preorder_node_yielder
        idx = 0

        dfs = ->(node, depth) {
          yield(node, depth, idx)
          idx += 1
          node.children.each { |child| dfs.(child, depth + 1) }
        }

        dfs.(chainable_node, 0)
        nil
      end
    end
  end
end
