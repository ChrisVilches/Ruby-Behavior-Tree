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

        raise 'Checking stack is empty (should be)' unless @stack.empty?

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
        raise "Chain must be used to chain a node or subtree, not a #{node.class}" unless node.is_a?(NodeBase)

        stack node
      end

      def respond_to_missing?
        true
      end

      # Convert a class name with namespace into a constant.
      # @param class_name [String]
      # @return [Class]
      def constantize(class_name)
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

        stack node_class.new(*final_args, &block)
      end

      alias t task
    end
  end
end

tree = BehaviorTree::Builder.build do
  inverter do
    seq do
      t do
        status.success!
      end
      force_failure do
        t do
          :empty
        end
      end
    end
  end
end

puts tree.class
raise 'Resulting object is not a tree' unless tree.is_a?(BehaviorTree::Tree)

initial_context = { a: 100 }

tree.context = initial_context

100.times do
  tree.tick!
end

puts "Final contest: #{tree.context}"
puts "Final tree status: #{tree.status.inspect}"
