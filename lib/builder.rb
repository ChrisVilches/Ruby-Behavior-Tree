# frozen_string_literal: true

require_relative './concerns/dsl/spell_checker'
require_relative './concerns/dsl/initial_config'

module BehaviorTree
  # DSL for building a tree.
  class Builder
    @node_type_mapping = {}
    class << self
      include Dsl::SpellChecker
      include Dsl::InitialConfig

      def build(&block)
        # Stack of lists. When a method like 'sequence' is executed, the resulting
        # sequence object will be stored in the last list. Then, the whole list will
        # be retrieved as the node children.
        @stack = []

        stack_children_from_block(block)
        tree_main_node = @stack.pop.first

        raise 'Tree structure is incorrect. Probably a problem with the library.' unless @stack.empty?

        BehaviorTree::Tree.new tree_main_node
      end

      # Don't validate class_name, because in some situations the user wants it to be evaluated
      # in runtime.
      def register(node_name, class_name, children: :none)
        valid_children_values = %i[none single multiple]
        raise "Children value must be in: #{valid_children_values}" unless valid_children_values.include?(children)

        node_name = node_name.to_sym
        raise RegisterDSLNodeAlreadyExistsError, node_name if @node_type_mapping.key?(node_name)

        @node_type_mapping[node_name] = {
          class:    class_name,
          children: children
        }
      end

      def register_alias(original, alias_key)
        unless @node_type_mapping.key?(original)
          raise "Cannot register alias for '#{original}', since it doesn't exist."
        end
        raise RegisterDSLNodeAlreadyExistsError, alias_key if @node_type_mapping.key?(alias_key)
        raise 'Alias key cannot be empty' if alias_key.to_s.empty?

        raise 'we have a problem here dude' if original == alias_key

        @node_type_mapping[original][:alias] = alias_key
        @node_type_mapping[alias_key] = @node_type_mapping[original].dup
        @node_type_mapping[alias_key][:alias] = original
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
        # TODO: If I don't add this, and I chain something like a 'nil', it still works,
        #       but crashes later. Maybe the validations in control nodes are lacking.
        unless node.is_a?(NodeBase)
          raise DSLStandardError, "The 'chain' keyword must be used to chain a node or subtree, not a #{node.class}"
        end

        stack node
      end

      def respond_to_missing?
        true
      end

      # Convert a class name with namespace into a constant.
      # It returns the class itself if it's already a class.
      # @param class_name [String]
      # @return [Class]
      def constantize(class_name)
        return class_name if class_name.is_a?(Class)

        class_name.split('::').compact.inject(Object) { |o, c| o.const_get c }
      rescue NameError
        nil
      end

      def dynamic_method_with_children(node_class, children, args, block)
        stack_children_from_block(block)
        final_args = [@stack.pop] + args # @stack.pop is already an Array
        final_args.flatten! unless children == :multiple
        stack node_class.new(*final_args)
      end

      def dynamic_method_leaf(node_class, args, block)
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
          dynamic_method_leaf(node_class, args, block)
        else
          dynamic_method_with_children(node_class, children, args, block)
        end
      end
    end

    BehaviorTree::Builder.initial_config
  end
end
