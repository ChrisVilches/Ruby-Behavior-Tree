# frozen_string_literal: true

require_relative '../node_base'

module BehaviorTree
  # A task (leaf) node.
  class TaskBase < NodeBase
    def initialize(&block)
      super

      @task_block = block
    end

    def on_tick
      eval 'self', @task_block.binding, __FILE__, __LINE__
      instance_eval(&@task_block)
    end

    private

    attr_reader :context
  end

  Task = TaskBase
end
