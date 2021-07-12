# frozen_string_literal: true

module BehaviorTree
  # DSL for building a tree.
  class Builder
    class << self
      include Dsl::SpellChecker

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

      private

      def nop(necessary_ticks)
        stack BehaviorTree::Nop.new(necessary_ticks)
      end

      def stack(obj)
        @stack.last << obj
      end

      def task(&block)
        stack BehaviorTree::TaskBase.new(&block)
      end

      # Execute @stack.pop after executing this method to
      # extract what was pushed.
      def stack_children_from_block(block)
        @stack << []
        eval 'self', block.binding, __FILE__, __LINE__
        instance_eval(&block)
      end

      def chain(node)
        # TODO: If I don't add this, and I chain something like a 'nil', it still works,
        #       but crashes later. Maybe the validations in control-flow nodes are lacking.
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

      def method_missing(name, *args, &block)
        # Find by name or alias.
        node_class_name = NODE_TYPE_MAPPING.dig name, :class

        node_class = constantize(node_class_name)

        raise_node_type_not_exists name if node_class.nil?

        children = NODE_TYPE_MAPPING.dig(name.to_sym, :children)

        stack_children_from_block(block)

        final_args = [@stack.pop] + args # @stack.pop is already an Array
        final_args.flatten! unless children == :multiple
        stack node_class.new(*final_args)
      end

      alias t task
    end
  end
end
