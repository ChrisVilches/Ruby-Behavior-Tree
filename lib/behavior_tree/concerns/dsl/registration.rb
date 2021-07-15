# frozen_string_literal: true

module BehaviorTree
  module Dsl
    # Register DSL commands.
    module Registration
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

        @node_type_mapping[original][:alias] = alias_key
        @node_type_mapping[alias_key] = @node_type_mapping[original].dup
        @node_type_mapping[alias_key][:alias] = original
      end
    end
  end
end
