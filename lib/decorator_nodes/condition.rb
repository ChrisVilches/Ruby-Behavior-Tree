# frozen_string_literal: true

require_relative './decorator_base'

module BehaviorTree
  module Decorators
    # Applies a condition that will decide whether to tick the decorated node or not.
    class Condition < DecoratorBase
      def initialize(child, procedure = nil, &block)
        validate_proc!(procedure, block)

        super(child)

        @conditional_block = block_given? ? block : procedure
      end

      protected

      def should_tick?
        if @conditional_block.lambda?
          args = [@context, self].take @conditional_block.arity
          @conditional_block.call(*args)
        else
          instance_eval(&@conditional_block)
        end
      end

      def status_map
        if @tick_prevented
          status.failure!
        else
          self.status = child.status
        end
      end

      private

      def validate_proc!(procedure, block)
        raise ArgumentError, 'Condition decorator must be given a block/procedure' unless block || procedure.is_a?(Proc)

        return if block.is_a?(Proc) ^ procedure.is_a?(Proc)

        raise ArgumentError, 'Pass a lambda/proc or block to a condition decorator, but not both'
      end

      attr_reader :context
    end
  end
end
