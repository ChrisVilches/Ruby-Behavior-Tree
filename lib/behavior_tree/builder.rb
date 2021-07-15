# frozen_string_literal: true

require_relative './concerns/dsl/spell_checker'
require_relative './concerns/dsl/initial_config'
require_relative './concerns/dsl/randomizer'
require_relative './concerns/dsl/registration'
require_relative './concerns/dsl/utils'

module BehaviorTree
  # DSL for building a tree.
  class Builder
    @node_type_mapping = {}
    class << self
      include Dsl::SpellChecker
      include Dsl::InitialConfig
      include Dsl::Randomizer
      include Dsl::Registration
      include Dsl::Utils

      def build(&block)
        # Stack of lists. When a method like 'sequence' is executed, the resulting
        # sequence object will be stored in the last list. Then, the whole list will
        # be retrieved as the node children.
        @stack = []

        stack_children_from_block(block)
        tree_main_nodes = @stack.pop

        raise DSLStandardError, 'Tree main node should be a single node' if tree_main_nodes.count > 1

        raise 'Tree structure is incorrect. Probably a problem with the library.' unless @stack.empty?

        BehaviorTree::Tree.new tree_main_nodes.first
      end

      private

      def stack(obj)
        @stack.last << obj
      end

      # Execute @stack.pop after executing this method to
      # extract what was pushed.
      def stack_children_from_block(block)
        @stack << []
        instance_eval(&block)
      end

      def chain(node)
        unless node.is_a?(NodeBase)
          raise DSLStandardError, "The 'chain' keyword must be used to chain a node or subtree, not a #{node.class}"
        end

        stack node
      end

      def respond_to_missing?(method_name, _include_private)
        @node_type_mapping.key? method_name
      end

      def exec_with_children(node_class, children_type, args, block)
        stack_children_from_block(block)
        children_nodes = @stack.pop
        raise DSLStandardError, "Node #{node_class} has no children." if children_nodes.empty?

        final_args = [children_nodes] + args # @stack.pop is already an Array
        final_args.flatten! unless children_type == :multiple
        stack node_class.new(*final_args)
      end

      def exec_leaf(node_class, args, block)
        stack node_class.new(*args, &block)
      end

      def method_missing(name, *args, &block)
        # Find by name or alias.
        node_class_name = @node_type_mapping.dig name, :class

        node_class = constantize(node_class_name)

        raise_node_type_not_exists name if node_class.nil?

        children = @node_type_mapping.dig(name.to_sym, :children)

        # Nodes that have children are executed differently from leaf nodes.
        if children == :none
          exec_leaf(node_class, args, block)
        else
          exec_with_children(node_class, children, args, block)
        end
      end
    end

    BehaviorTree::Builder.initial_config
  end
end
