# frozen_string_literal: true

describe BehaviorTree::TreeStructure::Algorithms do
  # NOTE: Variables must be first copied inside the 'let' scope before using 'chain', otherwise RSpec
  #       lazy evaluation fails (due to the DSL builder missing_method mechanism).

  let(:nop1) { BehaviorTree::Nop.new }
  let(:nop2) { BehaviorTree::Nop.new }

  let(:tree_selector_sequence_tasks) do
    nop1_ = nop1
    nop2_ = nop2
    BehaviorTree::Builder.build do
      sel do
        seq do
          chain nop1_
          chain nop2_
        end
        seq do
          t
        end
      end
    end
  end

  let(:tree_without_repeated_nodes) do
    nop1_ = nop1
    nop2_ = nop2
    BehaviorTree::Builder.build do
      inv do
        seq do
          t
          t
          sel do
            chain nop1_
            force_failure do
              chain nop2_
            end
          end
        end
      end
    end
  end

  let(:tree_with_repeated_task) do
    nop1_ = nop1

    BehaviorTree::Builder.build do
      inv do
        seq do
          t
          t
          sel do
            chain nop1_
            force_failure do
              chain nop1_
            end
          end
        end
      end
    end
  end

  let(:tree_with_cycle) do
    sequence = BehaviorTree::Sequence.new
    inverter = BehaviorTree::Decorators::Inverter.new sequence

    sequence << nop1
    sequence << inverter

    #           inv
    #            |
    #         sequence
    #         /     \
    #       nop     inv (*same as above)
    BehaviorTree::Tree.new inverter
  end

  let(:tree_with_long_cycle) do
    #             inv
    #              |
    #           sequence
    #              |
    #         force_failure
    #              |
    #             inv (*same as above)
    sequence = BehaviorTree::Sequence.new
    inverter = BehaviorTree::Decorators::Inverter.new sequence
    force_failure = BehaviorTree::Decorators::ForceFailure.new inverter
    sequence << force_failure
    BehaviorTree::Tree.new inverter
  end

  let(:tree_with_complex_cycle) do
    sequence = BehaviorTree::Sequence.new

    tree2 = BehaviorTree::Builder.build do
      sel do
        t
        chain sequence
        t
      end
    end

    tree1 = BehaviorTree::Builder.build do
      seq do
        t
        chain tree2
        t
      end
    end

    sequence << tree2
    tree1
  end

  describe '.repeated_nodes (and the similar method .uniq_nodes?)' do
    context 'has a repeated node (without cycles)' do
      subject { tree_with_repeated_task }
      it { expect(subject.uniq_nodes?).to be false }
      it { expect(subject.repeated_nodes.to_a).to eq [nop1] }
      it { expect(subject.repeated_nodes.size).to eq 1 }
    end

    context 'has no repeated node' do
      subject { tree_without_repeated_nodes }
      it { expect(subject.uniq_nodes?).to be true }
      it { expect(subject.repeated_nodes.to_a).to eq [] }
    end

    context 'has a cycle' do
      subject { tree_with_cycle }
      it 'detects the repeated node (not the cycle)' do
        expect(subject.uniq_nodes?).to be false
      end

      it 'detects the repeated node (the tree main node)' do
        expect(subject.repeated_nodes.to_a).to eq [subject.chainable_node]
      end
    end
  end

  describe '.cycle?' do
    subject { tree.cycle? }
    context 'has a repeated node (without cycles)' do
      let(:tree) { tree_with_repeated_task }
      it { is_expected.to be false }
    end

    context 'has no repeated node' do
      let(:tree) { tree_without_repeated_nodes }
      it { is_expected.to be false }
    end

    context 'has a cycle' do
      let(:tree) { tree_with_cycle }
      it { is_expected.to be true }
    end

    context 'has a long cycle' do
      let(:tree) { tree_with_long_cycle }
      it { is_expected.to be true }
    end

    context 'has a complex cycle' do
      let(:tree) { tree_with_complex_cycle }
      it { is_expected.to be true }
    end
  end

  describe '.each_node' do
    let(:result) do
      tree_selector_sequence_tasks.each_node(traverse_type).map do |node, depth, idx|
        [node, depth, idx]
      end
    end

    # Convert class names into the first three letters downcased (Sequence -> seq).
    let(:result_nodes) { result.map { |r| r.first.class.name.split('::').last[..2].downcase } }
    let(:result_depth) { result.map { |r| r[1] } }
    let(:result_indexes) { result.map(&:last) }

    shared_examples :indexes_are_ordered do
      it { expect(result_indexes).to eq (0...result_indexes.count).to_a }
    end
    context 'BFS' do
      let(:traverse_type) { :breadth }
      it_behaves_like :indexes_are_ordered
      it { expect(result_nodes).to eq %w[sel seq seq nop nop tas] }
      it { expect(result_depth).to eq [0, 1, 1, 2, 2, 2] }
    end

    context 'DFS preorder' do
      let(:traverse_type) { :depth_preorder }
      it_behaves_like :indexes_are_ordered
      it { expect(result_nodes).to eq %w[sel seq nop nop seq tas] }
      it { expect(result_depth).to eq [0, 1, 2, 2, 1, 2] }
    end

    context 'DFS postorder' do
      let(:traverse_type) { :depth_postorder }
      it_behaves_like :indexes_are_ordered
      it { expect(result_nodes).to eq %w[nop nop seq tas seq sel] }
      it { expect(result_depth).to eq [2, 2, 1, 2, 1, 0] }
    end

    context 'incorrect traversal type' do
      let(:traverse_type) { :invalid }
      it { expect { result }.to raise_error(ArgumentError).with_message(/must be in/) }
    end
  end
end
