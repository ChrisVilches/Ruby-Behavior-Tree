# frozen_string_literal: true

require_relative './task'

module BehaviorTree
  # An empty task that does not do anything.
  # It requires N ticks to complete.
  class Nop < Task
    def initialize(necessary_ticks = 1, completes_with_status: BehaviorTree::NodeStatus::SUCCESS)
      raise ArgumentError, 'Should need at least one tick' if necessary_ticks < 1

      super()
      @necessary_ticks = necessary_ticks
      @completes_with_status = completes_with_status
      reset
    end

    def tick!
      super

      @required_ticks -= 1
      return if @required_ticks.positive?

      status.set @completes_with_status
      reset
    end

    def halt!
      super
      reset
    end

    private

    def reset
      @required_ticks = @necessary_ticks
    end
  end
end
