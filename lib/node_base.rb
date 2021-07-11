# frozen_string_literal: true

module BehaviorTree
  # A node (abstract class).
  class NodeBase
    attr_reader :status, :tick_count

    def initialize
      @status = NodeStatus.new NodeStatus::SUCCESS
      @tick_count = 0
    end

    def tick!
      status.running!
      # TODO: At the moment, this is only used in tests, and all nodes tested are tasks.
      #       Modify it so that only tasks do this?
      @tick_count += 1
    end

    def status=(other_status)
      status.running! if other_status.running?
      status.failure! if other_status.failure?
      status.success! if other_status.success?
      status
    end

    def halt!
      status.success!
    end
  end

  private_constant :NodeBase
end