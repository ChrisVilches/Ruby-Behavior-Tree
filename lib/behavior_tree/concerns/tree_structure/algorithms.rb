# frozen_string_literal: true

module BehaviorTree
  module TreeStructure
    # Basic tree algorithms.
    module Algorithms
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

      def each_node(traversal_type = TRAVERSAL_TYPES.first, &block)
        return enum_for(:each_node, traversal_type) unless block_given?

        raise ArgumentError, "Traversal type must be in: #{TRAVERSAL_TYPES}" unless TRAVERSAL_TYPES.any?(traversal_type)

        send("#{traversal_type}_node_yielder", &block)
        nil
      end

      private

      def breadth_node_yielder
        queue = [[chainable_node, 0, self]]
        idx = 0
        depth = 0
        until queue.empty?
          node, depth, parent_node = queue.shift # Remove first
          # Enqueue node with depth and parent.
          queue.concat(node.children.map { |child| [child, depth + 1, node] })
          yield(node, depth, idx, parent_node)
          idx += 1
        end
      end

      def depth_postorder_node_yielder
        idx = 0

        dfs = ->(node, depth, parent_node) {
          node.children.each { |child| dfs.(child, depth + 1, node) }
          yield(node, depth, idx, parent_node)
          idx += 1
        }

        dfs.(chainable_node, 0, self)
      end

      def depth_preorder_node_yielder
        idx = 0

        dfs = ->(node, depth, parent_node) {
          yield(node, depth, idx, parent_node)
          idx += 1
          node.children.each { |child| dfs.(child, depth + 1, node) }
        }

        dfs.(chainable_node, 0, self)
      end

      TRAVERSAL_TYPES = %i[depth_postorder depth_preorder breadth].freeze
    end
  end
end
