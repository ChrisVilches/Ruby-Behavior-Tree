# frozen_string_literal: true

module BehaviorTree
  # A node (abstract class).
  class NodeBase
    include TreeStructure::Algorithms
    attr_reader :status, :tick_count, :ticks_running, :arbitrary_storage

    def initialize
      @status = NodeStatus.new NodeStatus::SUCCESS
      @tick_count = 0
      @ticks_running = 0
      @context = nil

      @status.subscribe { |prev, curr| __on_status_change__(prev, curr) }

      @arbitrary_storage = {}
    end

    def context=(context)
      @context = context

      # Propagate context.
      children.each do |child|
        child.context = context
      end
    end

    def size
      1 + children.map(&:size).sum
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

      # NOTE: Make sure this method returns nil. Since 'ensure_after_tick' might return
      #       the node status, it generates some error in IRB (unknown cause).
      #
      #       This error can be replicated by pasting a valid status object in IRB, such as by doing:
      #       BehaviorTree.const_get(:NodeStatus).new(:__running__) # Valid, but IRB crashes.
      #
      #       Ruby 3.0.0 -> Crash
      #       Ruby 2.7.0 -> OK
      nil
    end

    def children
      if @children.is_a?(Array)
        @children
      elsif @child.is_a?(NodeBase)
        [@child]
      else
        []
      end
    end

    def chainable_node
      self
    end

    def []=(key, value)
      @arbitrary_storage[key] = value
    end

    def [](key)
      @arbitrary_storage[key]
    end

    def status=(other_status)
      status.running! if other_status.running?
      status.failure! if other_status.failure?
      status.success! if other_status.success?
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

    def on_status_change(_prev, _curr); end

    private

    # Always prev != curr (states that are set to the same aren't notified).
    # The fact that it's set to 0 means that setting to running must be done before
    # increasing the counts (so that @ticks_running becomes 1 after the whole tick lifecycle).
    # This is the non custom on_status_change. Users are expected to override the one without
    # double underscore if they want to execute custom logic.
    def __on_status_change__(prev, curr)
      if prev == NodeStatus::RUNNING
        on_finished_running
      elsif curr == NodeStatus::RUNNING
        @ticks_running = 0
        on_started_running
      end

      on_status_change(prev, curr)
    end
  end

  private_constant :NodeBase
end
