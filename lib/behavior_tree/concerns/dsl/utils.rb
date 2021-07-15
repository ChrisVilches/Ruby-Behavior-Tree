# frozen_string_literal: true

module BehaviorTree
  module Dsl
    # Helpers for DSL.
    module Utils
      private

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
    end
  end
end
