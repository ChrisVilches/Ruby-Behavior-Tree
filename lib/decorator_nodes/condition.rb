# frozen_string_literal: true

require_relative './decorator_base'

module BehaviorTree
  module Decorators
    # Applies a condition that will decide whether to tick the decorated node or not.
    class Condition < DecoratorBase
      def initialize(child, procedure = nil, &block)
        raise ArgumentError, 'Condition decorator must be given a block' unless block_given? || procedure.is_a?(Proc)

        super(child)

        @conditional_block = block_given? ? block : procedure
      end

      protected

      def should_tick?
        eval 'self', @conditional_block.binding, __FILE__, __LINE__
        instance_eval(&@conditional_block)
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
