# frozen_string_literal: true

module BehaviorTree
  module NodeIterators
    # If there's at least one node with 'running' status, then iterate starting from there, in order.
    # Else, iterate all nodes.
    module PrioritizeRunning
      private

      def prioritize_running
        @first_running_idx = children.find_index { |child| child.status.running? }.to_i if must_recompute_idx?

        Enumerator.new do |y|
          children[@first_running_idx..].each do |child|
            y << child
          end
        end
      end

      def must_recompute_idx?
        !@first_running_idx || !children[@first_running_idx].status.running?
      end
    end
  end
end
