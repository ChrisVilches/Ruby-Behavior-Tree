# frozen_string_literal: true

require_relative './task'

module BehaviorTree
  # An empty task that does not do anything.
  # It requires N ticks to complete.
  # It can be set to end with failure
  class Nop < Task
    def initialize(necessary_ticks = 1, completes_with_failure: false)
      raise ArgumentError, 'Should need at least one tick' if necessary_ticks < 1

      super()
      @necessary_ticks = necessary_ticks
      @completes_with_status = completes_with_failure ? NodeStatus::FAILURE : NodeStatus::SUCCESS
      reset
    end

    def tick!
      super

      @remaining_ticks -= 1
      return if @remaining_ticks.positive?

      status.set @completes_with_status
      reset
    end

    def halt!
      super
      reset
    end

    private

    def reset
      @remaining_ticks = @necessary_ticks
    end
  end
end
