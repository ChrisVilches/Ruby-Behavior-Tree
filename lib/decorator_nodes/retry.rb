# frozen_string_literal: true

module BehaviorTree
  module Decorators
    # Repeat N times while child has failure status.
    class Retry < RepeatTimesBase
      protected

      def repeat_while
        child.status.failure?
      end
    end
  end
end
