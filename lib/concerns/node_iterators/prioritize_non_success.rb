# frozen_string_literal: true

module BehaviorTree
  module NodeIterators
    # If there's at least one node without 'success' status, then iterate starting from there, in order.
    # Else, iterate all nodes.
    module PrioritizeNonSuccess
      def non_success
        idx = @children.find_index { |child| !child.status.success? }

        Enumerator.new do |y|
          @children[idx..].each do |child|
            y << child
          end
        end
      end
    end
  end
end
