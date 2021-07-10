# frozen_string_literal: true

module BehaviorTree
  # Status for nodes.
  class NodeStatus
    SUCCESS = :__success__
    RUNNING = :__running__
    FAILURE = :__failure__

    def initialize(value)
      set(value)
    end

    def set(value)
      raise IncorrectStatusValueError, value unless [SUCCESS, RUNNING, FAILURE].include?(value)

      @value = value
    end

    def ==(other)
      to_sym == other.to_sym
    end

    def inspect
      to_sym
    end

    def to_sym
      return :success if success?
      return :running if running?
      return :failure if failure?
    end

    def success!
      set(SUCCESS)
    end

    def running!
      set(RUNNING)
    end

    def failure!
      set(FAILURE)
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

  private_constant :NodeStatus
end
