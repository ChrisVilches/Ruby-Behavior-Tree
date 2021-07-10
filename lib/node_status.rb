# frozen_string_literal: true

module BehaviorTree
  # Exception for when a node has an incorrect status value.
  class IncorrectStatusValue < StandardError
    def initialize(value)
      super "Incorrect status value. A node cannot have '#{value}' status."
    end
  end
end

module BehaviorTree
  # Status for nodes.
  class NodeStatus
    SUCCESS = :_success
    RUNNING = :_running
    FAILURE = :_failure

    def initialize(value)
      set(value)
    end

    def set(value)
      raise IncorrectStatusValue, value unless [SUCCESS, RUNNING, FAILURE].include?(value)

      @value = value
    end

    def success!
      @value = SUCCESS
    end

    def running!
      @value = RUNNING
    end

    def failure!
      @value = FAILURE
    end

    def success?
      @value == SUCCESS
    end

    def running?
      @value == RUNNING
    end

    def failure?
      @value == FAILURE
    end
  end
end
