# frozen_string_literal: true

require_relative '../node_base'

module BehaviorTree
  # A node that has children (abstract class).
  class ControlNodeBase < NodeBase
    include NodeIterators::PrioritizeNonSuccess
    include NodeIterators::AllNodes

    def initialize(children = [])
      unless respond_to?(traversal_strategy, true)
        err = "Iteration strategy named '#{traversal_strategy}' does not exist."
        raise NoMethodError, err
      end

      super()
      @children = children
    end

    def traversal_strategy
      # NOTE: This means that a long chain of inheritance would not be able to provide
      #       a default traversal_strategy value. It'd be necessary to traverse the
      #       entire class hierarchy to find a present value.
      self.class.traversal_strategy || self.class.superclass.traversal_strategy
    end

    def <<(child)
      @children << child
      @children.flatten! # Accepts array of children too.
      @children.map!(&:chainable_node)
    end

    def halt!
      validate_non_leaf!

      super

      @children.each(&:halt!)
    end

    protected

    def on_tick
      raise NotImplementedError, 'Must implement control logic'
    end

    def validate_non_leaf!
      raise InvalidLeafNodeError if @children.empty?
    end

    def tick_each_children(&block)
      return enum_for(:tick_each_children) unless block_given?

      validate_non_leaf!

      Enumerator.new do |y|
        enum = send(traversal_strategy)
        validate_enum!(enum)

        enum.each do |child|
          child.tick!
          y << child
        end
      end.each(&block)
    end

    # Keep it simple, because it's executed everytime it ticks.
    def validate_enum!(enum)
      raise IncorrectTraversalStrategyError, enum unless enum.respond_to? :each
    end

    class << self
      attr_reader :traversal_strategy

      private

      def children_traversal_strategy(traversal_strategy)
        @traversal_strategy = traversal_strategy
      end
    end

    children_traversal_strategy :prioritize_non_success
  end
end
