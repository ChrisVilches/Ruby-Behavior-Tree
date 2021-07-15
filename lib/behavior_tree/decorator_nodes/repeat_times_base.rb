# frozen_string_literal: true

module BehaviorTree
  module Decorators
    # While the node status is <repeat_while>, tick it again up to N times.
    # Interrupt the loop when the <repeat_while> condition fails.
    # If the child returns running, this node returns running too.
    # The count is resetted when the loop is interrupted or finished.
    # N is the total times to be ticked, and it includes the initial tick (the
    # original tick that all nodes have in common).
    class RepeatTimesBase < DecoratorBase
      def initialize(child, max)
        validate_max!(max)
        super(child)

        @max = max
        reset_remaining_attempts
      end

      def decorate
        while repeat_while || child.status.running?
          break if child.status.running?

          @remaining_attempts -= 1
          break unless @remaining_attempts.positive?

          child.tick!
          break if child.status.running?
        end
      end

      protected

      def repeat_while
        raise NotImplementedError
      end

      private

      def reset_remaining_attempts
        @remaining_attempts = @max
      end

      def validate_max!(max)
        return if max.is_a?(Integer) && max.positive?

        raise ArgumentError, 'Number of repetitions must be a positive integer.'
      end
    end

    private_constant :RepeatTimesBase
  end
end
