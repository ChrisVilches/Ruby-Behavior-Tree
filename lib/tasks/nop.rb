# frozen_string_literal: true

require_relative './task_base'

module BehaviorTree
  # An empty task that does not do anything.
  # It requires N ticks to complete.
  # It can be set to end with failure.
  class Nop < TaskBase
    def initialize(necessary_ticks = 1, completes_with_failure: false)
      raise ArgumentError, 'Should need at least one tick' if necessary_ticks < 1

      super()
      @necessary_ticks = necessary_ticks
      @completes_with_status = completes_with_failure ? NodeStatus::FAILURE : NodeStatus::SUCCESS
      reset_remaining_attempts
    end

    def tick!
      super

      @remaining_ticks -= 1
      return if @remaining_ticks.positive?

      status.set @completes_with_status
      reset_remaining_attempts
    end

    def halt!
      super
      reset_remaining_attempts
    end

    private

    def reset_remaining_attempts
      @remaining_ticks = @necessary_ticks
    end
  end
end
