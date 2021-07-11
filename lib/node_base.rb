# frozen_string_literal: true

module BehaviorTree
  # A node (abstract class).
  class NodeBase
    attr_reader :status, :tick_count
    attr_writer :context

    def initialize
      @status = NodeStatus.new NodeStatus::SUCCESS
      @tick_count = 0
      @context = nil
    end

    def tick!
      prevented = prevent_tick?.is_a?(TrueClass)

      unless prevented
        status.running!
        pre_tick
        on_tick
        after_tick
        @tick_count += 1
      end

      ensure_after_tick
    end

    def chainable_node
      self
    end

    def prevent_tick?
      false
    end

    def after_tick; end

    def pre_tick; end

    def on_tick; end

    def ensure_after_tick; end

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
