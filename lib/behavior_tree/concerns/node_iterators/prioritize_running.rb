# frozen_string_literal: true

module BehaviorTree
  module NodeIterators
    # If there's at least one node with 'running' status, then iterate starting from there, in order.
    # Else, iterate all nodes.
    module PrioritizeRunning
      def prioritize_running
        idx = @children.find_index { |child| child.status.running? }.to_i

        Enumerator.new do |y|
          @children[idx..].each do |child|
            y << child
          end
        end
      end
    end
  end
end
