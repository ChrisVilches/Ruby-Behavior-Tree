# frozen_string_literal: true

module BehaviorTree
  module Decorators
    # Repeat N times while child has success status.
    class Repeater < RepeatTimesBase
      protected

      def repeat_while
        child.status.success?
      end
    end
  end
end
