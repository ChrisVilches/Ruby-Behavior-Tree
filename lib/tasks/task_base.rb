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
      @task_block.call @context, status
    end
  end
end
