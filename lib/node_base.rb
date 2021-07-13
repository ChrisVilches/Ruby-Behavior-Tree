# frozen_string_literal: true

module BehaviorTree
  # A node (abstract class).
  class NodeBase
    attr_reader :status, :tick_count

    def initialize
      @status = NodeStatus.new NodeStatus::SUCCESS
      @tick_count = 0
      @ticks_running = 0
      @context = nil

      @status.subscribe { |prev, curr| on_status_change(prev, curr) }

      # As the name implies, this is arbitrary data that's only accessible from
      # the parent. For node-scoped data, simply use @ variables as usual.
      #
      # Nothing prevents other objects or itself from accessing it, though.
      @parent_managed_arbitrary_storage = {}
    end

    def context=(context)
      @context = context

      # Propagate context.
      if @children.is_a?(Array)
        @children.each do |child|
          child.context = context
        end
      elsif @child.is_a?(NodeBase)
        @child.context = context
      end
    end

    def size
      1 + if @children.is_a?(Array)
            @children.map(&:size).sum
          elsif @child.is_a?(NodeBase)
            @child.size
          else
            0
          end
    end

    def tick!
      @tick_count += 1
      @tick_prevented = !should_tick?

      unless @tick_prevented
        status.running!
        on_tick
        @ticks_running += 1
      end

      ensure_after_tick
    end

    def children
      if @children
        @children
      elsif @child
        [@child]
      else
        []
      end
    end

    def chainable_node
      self
    end

    def []=(key, value)
      @parent_managed_arbitrary_storage[key] = value
    end

    def [](key)
      @parent_managed_arbitrary_storage[key]
    end

    def arbitrary_storage
      @parent_managed_arbitrary_storage.dup.freeze
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

    protected

    # If this value is false, @tick_prevented will be set to true, which can be handled in other
    # tick callbacks.
    def should_tick?
      true
    end

    def on_tick; end

    def ensure_after_tick; end

    def on_started_running; end

    def on_finished_running; end

    private

    # Always prev != curr (states that are set to the same aren't notified).
    # The fact that it's set to 0 means that setting to running must be done before
    # increasing the counts (so that @ticks_running becomes 1 after the whole tick lifecycle).
    def on_status_change(prev, curr)
      if prev == NodeStatus::RUNNING
        on_finished_running
      elsif curr == NodeStatus::RUNNING
        @ticks_running = 0
        on_started_running
      end
    end
  end

  private_constant :NodeBase
end
