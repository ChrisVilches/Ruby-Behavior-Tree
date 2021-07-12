# frozen_string_literal: true

describe BehaviorTree::Builder do
  let(:tree1) do
    BehaviorTree::Builder.build do
      inverter do
        task { status.success! }
      end
    end
  end

  before :all do
    BehaviorTree::Builder.register(:nop, BehaviorTree::Nop, children: :none)
  end

  let(:tree2) do
    # NOTE: I wanted to use tree1 defined above, but
    #       the scope of the block doesn't find it.
    #       But it seems this only happens in RSpec.
    another_tree = BehaviorTree::Builder.build do
      inverter do
        task { status.success! }
      end
    end

    BehaviorTree::Builder.build do
      inverter do
        seq do
          t
          sel do
            re_try 6 do
              chain another_tree
            end
          end
          t
          task { status.success! }
          sel do
            repeater 4 do
              sel do
                nop 3
                nop 1
              end
            end
          end
        end
      end
    end
  end

  context 'tree with inverter and task' do
    it { expect(tree1.size).to eq 3 }
  end

  context 'many nodes' do
    it { expect(tree2.size).to eq 15 }
  end
end
