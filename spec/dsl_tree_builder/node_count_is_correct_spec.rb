# frozen_string_literal: true

describe BehaviorTree::Builder do
  let(:tree1) do
    described_class.build do
      inverter do
        task { status.success! }
      end
    end
  end
  let(:tree2) do
    another_tree = tree1

    described_class.build do
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

  before :all do
    described_class.register(:nop, BehaviorTree::Nop, children: :none)
  end

  context 'tree with inverter and task' do
    it { expect(tree1.size).to eq 3 }
  end

  context 'many nodes' do
    it { expect(tree2.size).to eq 15 }
  end
end
