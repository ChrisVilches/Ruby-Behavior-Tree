# frozen_string_literal: true

module BehaviorTree
  module Dsl
    # Helpers for spellchecking, and correcting user input in the DSL builder.
    module SpellChecker
      node_type_mapping = {
        re_try:        { class: 'BehaviorTree::Decorators::Retry', children: :single },
        inverter:      { class: 'BehaviorTree::Decorators::Inverter', children: :single },
        repeater:      { class: 'BehaviorTree::Decorators::Repeater', children: :single },
        force_failure: { class: 'BehaviorTree::Decorators::ForceFailure', children: :single },
        force_success: { class: 'BehaviorTree::Decorators::ForceSuccess', children: :single },
        sequence:      { class: 'BehaviorTree::Sequence', children: :multiple },
        selector:      { class: 'BehaviorTree::Selector', children: :multiple }
      }

      # Apply aliases
      node_alias = {
        sequence: :seq,
        selector: :sel,
        repeater: :rep,
        inverter: :inv
      }.map do |k, v|
        node_type_mapping[k][:alias] = v
        [v, node_type_mapping[k].merge(alias: k)]
      end.to_h

      NODE_TYPE_MAPPING = node_type_mapping.merge(node_alias)

      def raise_node_type_not_exists(missing_method)
        suggestion = most_similar_name missing_method
        method_alias = NODE_TYPE_MAPPING.dig suggestion, :alias
        raise NodeTypeDoesNotExistError.new(missing_method, suggestion, method_alias)
      end

      def most_similar_name(name)
        return nil if (defined? DidYouMean).nil?

        DidYouMean::SpellChecker.new(dictionary: NODE_TYPE_MAPPING.keys)
                                .correct(name)&.first
      end
    end
  end
end
