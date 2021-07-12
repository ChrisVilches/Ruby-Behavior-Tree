# frozen_string_literal: true

describe BehaviorTree::Builder do
  let(:tree_using_alias) do
    BehaviorTree::Builder.build do
      inverter do
        seqq do
          :empty
        end
      end
    end
  end

  let(:tree) do
    BehaviorTree::Builder.build do
      inverter do
        sequencee do
          :empty
        end
      end
    end
  end

  context 'incorrect node type (not using alias, i.e. using the full name)' do
    it { expect { tree }.to raise_error BehaviorTree::NodeTypeDoesNotExistError }
    it { expect { tree }.to raise_error.with_message(/'sequence'/) }
    it { expect { tree }.to raise_error.with_message(/alias of seq/) }
  end

  context 'incorrect node type (using alias, i.e. shorter name)' do
    it { expect { tree_using_alias }.to raise_error BehaviorTree::NodeTypeDoesNotExistError }
    it { expect { tree_using_alias }.to raise_error.with_message(/'seq'/) }
    it { expect { tree_using_alias }.to raise_error.with_message(/alias of sequence/) }
  end
end
