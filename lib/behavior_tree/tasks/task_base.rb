# frozen_string_literal: true

require_relative '../node_base'
require_relative '../concerns/validations/proc_or_block'

module BehaviorTree
  # A task (leaf) node.
  class TaskBase < NodeBase
    include Validations::ProcOrBlock

    def initialize(procedure = nil, &block)
      validate_proc!(procedure, block)

      super()

      @task_block = block_given? ? block : procedure
    end

    def on_tick
      raise 'Node should be set to running' unless status.running?
      return unless @task_block.is_a?(Proc)

      if @task_block.lambda?
        args = [@context, self].take @task_block.arity
        @task_block.(*args)
      else
        instance_eval(&@task_block)
      end
    end

    private

    attr_reader :context
  end

  Task = TaskBase
end
