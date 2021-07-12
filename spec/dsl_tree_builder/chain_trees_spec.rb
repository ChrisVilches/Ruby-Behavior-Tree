# frozen_string_literal: true

describe BehaviorTree::Builder do
  let(:initial_context) { { a: 5 } }

  let(:dsl_tree_with_chained_oo_tree) do
    selector = BehaviorTree::Selector.new
    5.times { selector << BehaviorTree::TaskBase.new { :empty_block } }
    oo_tree = BehaviorTree::Tree.new(selector)

    BehaviorTree::Builder.build do
      inverter do
        chain(oo_tree)
      end
    end
  end

  let(:oo_tree_with_chained_dsl_tree) do
    dsl_tree = BehaviorTree::Builder.build do
      inverter do
        seq do
          t { :empty_block }
          t { :empty_block }
        end
      end
    end

    sequence = BehaviorTree::Selector.new
    3.times { sequence << BehaviorTree::TaskBase.new { :empty_block } }
    sequence << dsl_tree
    BehaviorTree::Tree.new(sequence)
  end

  # Describes how chaining trees built in different ways (object oriented or DSL) can be possible.
  describe '.chain' do
    context 'DSL tree contains OO tree' do
      it { expect(dsl_tree_with_chained_oo_tree.size).to eq 8 }
    end

    context 'OO tree contains DSL tree' do
      it { expect(oo_tree_with_chained_dsl_tree.size).to eq 9 }
    end

    context 'chain used in the first node' do
      let(:tree) do
        tree = BehaviorTree::Builder.build { seq { t } }
        BehaviorTree::Builder.build { chain tree }
      end
      it { expect(tree.size).to eq 3 }
    end

    context 'tree to be chained is not valid tree' do
      it do
        expect { BehaviorTree::Builder.build { chain nil } }.to raise_error BehaviorTree::DSLStandardError
      end
    end
  end
end
