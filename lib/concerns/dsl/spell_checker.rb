# frozen_string_literal: true

module BehaviorTree
  module Dsl
    # Helpers for spellchecking, and correcting user input in the DSL builder.
    module SpellChecker
      def raise_node_type_not_exists(missing_method)
        suggestion = most_similar_name missing_method
        method_alias = @node_type_mapping.dig suggestion, :alias
        raise NodeTypeDoesNotExistError.new(missing_method, suggestion, method_alias)
      end

      def most_similar_name(name)
        return nil if (defined? DidYouMean).nil?

        DidYouMean::SpellChecker.new(dictionary: @node_type_mapping.keys)
                                .correct(name)&.first
      end
    end
  end
end
