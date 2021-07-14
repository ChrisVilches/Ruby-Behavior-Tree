# frozen_string_literal: true

module BehaviorTree
  module Validations
    # Validates that only one (procedure or block) is present. None present is also valid.
    module ProcOrBlock
      private

      def validate_proc!(procedure, block)
        return if block.nil? && procedure.nil?
        return if block.is_a?(Proc) ^ procedure.is_a?(Proc)

        raise ArgumentError, 'Pass a lambda/proc or block to a condition decorator, but not both'
      end
    end
  end
end
