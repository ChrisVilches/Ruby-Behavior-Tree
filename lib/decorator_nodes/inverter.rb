# frozen_string_literal: true

module BehaviorTree
  module Decorators
    # Returns the inverted child status.
    class Inverter < DecoratorBase
      def decorate
        return status.running! if child.status.running?
        return status.failure! if child.status.success?
        return status.success! if child.status.failure?
      end
    end
  end
end
