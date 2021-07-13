# frozen_string_literal: true

describe BehaviorTree::TreeStructure::Algorithms do
  # NOTE: Variables must be first copied inside the 'let' scope before using 'chain', otherwise RSpec
  #       lazy evaluation fails (due to the DSL builder missing_method mechanism).

  let(:nop1) { BehaviorTree::Nop.new }
  let(:nop2) { BehaviorTree::Nop.new }

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
end
