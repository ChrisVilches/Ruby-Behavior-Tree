# frozen_string_literal: true

module BehaviorTree
  module Dsl
    # Generates random trees.
    module Randomizer
      def build_random_tree(recursion_amount: 10)
        raise ArgumentError, 'Recursion amount must be greater than 0' if recursion_amount < 1

        build do
          send(%i[sel seq].sample) do
            rand(3..5).times { recurse(recursion_amount).() }
          end
        end
      end

      private

      def recurse(recursions_left)
        return random_leaf_blocks.sample if recursions_left.zero?

        recursions_left -= 1

        # Repeated values in order to increase the weight for some type of nodes.
        %i[
          control decorated condition
          control decorated condition
          leaf
        ].map { |type| send("random_#{type}_blocks", recursions_left) }
          .concat
          .flatten
          .sample
      end

      def random_control_blocks(recursions_left)
        [
          proc { sel { rand(2..3).times { recurse(recursions_left).() } } },
          proc { seq { rand(2..3).times { recurse(recursions_left).() } } }
        ]
      end

      def random_decorated_blocks(recursions_left)
        [
          proc { force_success(&recurse(recursions_left)) },
          proc { force_failure(&recurse(recursions_left)) },
          proc { inv(&recurse(recursions_left)) },
          proc { re_try(2, &recurse(recursions_left)) },
          proc { repeater(2, &recurse(recursions_left)) }
        ]
      end

      def random_condition_blocks(recursions_left)
        [
          proc {
            cond(-> { rand > 0.2 }, &recurse(recursions_left))
          },
          proc {
            cond(-> { rand > 0.8 }, &recurse(recursions_left))
          }
        ]
      end

      def random_leaf_blocks(_recursions_left = nil)
        task = proc do
          task do
            # Weights.
            running_w = 3
            success_w = 1
            failure_w = 2
            new_status = (([:running] * running_w) + ([:success] * success_w) + ([:failure] * failure_w)).sample
            status.send("#{new_status}!")
          end
        end
        [task]
      end
    end
  end
end
