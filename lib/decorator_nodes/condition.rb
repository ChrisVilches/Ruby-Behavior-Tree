# frozen_string_literal: true

require_relative './decorator_base'

module BehaviorTree
  module Decorators
    # Applies a condition that will decide whether to tick the decorated node or not.
    class Condition < DecoratorBase
      include Validations::ProcOrBlock

      def initialize(child, procedure = nil, &block)
        validate_proc!(procedure, block)

        super(child)

        @conditional_block = block_given? ? block : procedure
      end

      protected

      def should_tick?
        return false unless @conditional_block.is_a?(Proc)

        if @conditional_block.lambda?
          args = [@context, self].take @conditional_block.arity
          @conditional_block.(*args)
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

      attr_reader :context
    end
  end
end
