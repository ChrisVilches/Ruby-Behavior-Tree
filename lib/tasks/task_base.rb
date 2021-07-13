# frozen_string_literal: true

require_relative '../node_base'

module BehaviorTree
  # A task (leaf) node.
  class TaskBase < NodeBase
    def initialize(&block)
      super

      @task_block = block
    end

    def void?
      !@task_block
    end

    def on_tick
      raise 'Node should be set to running' unless status.running?

      instance_eval(&@task_block)
    end

    private

    attr_reader :context
  end

  Task = TaskBase
end
