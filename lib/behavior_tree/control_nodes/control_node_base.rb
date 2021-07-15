# frozen_string_literal: true

require_relative '../node_base'
require_relative '../concerns/node_iterators/prioritize_running'
require_relative '../concerns/node_iterators/all_nodes'

module BehaviorTree
  # A node that has children (abstract class).
  class ControlNodeBase < NodeBase
    include NodeIterators::PrioritizeRunning
    include NodeIterators::AllNodes

    def initialize(children = [])
      raise IncorrectTraversalStrategyError, nil.class if traversal_strategy.nil?
      raise IncorrectTraversalStrategyError, traversal_strategy unless respond_to?(traversal_strategy, true)

      super()
      @children = children
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

    private

    def traversal_strategy
      self.class.traversal_strategy
    end

    # Keep it simple, because it's executed everytime it ticks.
    def validate_enum!(enum)
      raise IncorrectTraversalStrategyError, enum unless enum.respond_to? :each
    end

    class << self
      def traversal_strategy
        @traversal_strategy ||= ancestors.find do |constant|
          next if constant == self
          next unless constant.is_a? Class
          next unless constant.respond_to? :traversal_strategy
          next if constant.traversal_strategy.nil?

          break constant.traversal_strategy
        end
      end

      private

      def children_traversal_strategy(traversal_strategy)
        @traversal_strategy = traversal_strategy
      end
    end

    children_traversal_strategy :prioritize_running
  end
end
