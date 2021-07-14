# frozen_string_literal: true

require_relative './repeat_times_base'

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
