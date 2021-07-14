# frozen_string_literal: true

require_relative './decorator_base'

module BehaviorTree
  module Decorators
    # Returns the inverted child status.
    class Inverter < DecoratorBase
      protected

      def status_map
        return status.running! if child.status.running?
        return status.failure! if child.status.success?
        return status.success! if child.status.failure?
      end
    end
  end
end
