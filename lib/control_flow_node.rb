# frozen_string_literal: true

require_relative './node'

module BehaviorTree
  # A node that has children (abstract class).
  class ControlFlowNode < Node
    def initialize(children = [])
      super()
      @children = children
    end

    def tick!
      status.running!
    end

    def <<(child)
      @children << child
    end

    def halt!
      status.success!
      @children.each(&:halt!)
    end

    def tick_each_children(children = @children, &block)
      children.map do |child|
        child.tick!
        block&.call(child)
        child.status
      end
    end

    # If there's at least one node without 'success' status, then continue from there, in order.
    # Else, tick all nodes.
    def resume_tick_each_children(&block)
      index_running = @children.find_index { |node| !node.status.success? }
      filtered_children = @children[index_running..] # If index is nil, returns entire array.
      tick_each_children filtered_children, &block
    end
  end

  # TODO: Set as private. Can be done but Rspec fails.
  # private_constant :ControlFlowNode
end
