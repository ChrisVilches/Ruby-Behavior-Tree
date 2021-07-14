# frozen_string_literal: true

describe BehaviorTree::Builder do
  let(:tree_valid) do
    described_class.build do
      t
    end
  end
  let(:tree_invalid) do
    described_class.build do
      t
      t
    end
  end
  describe '.build' do
    context 'tree has a single node' do
      it { expect { tree_valid }.to_not raise_error }
    end
    context 'tree has multiple nodes' do
      it do
        expect { tree_invalid }.to raise_error(BehaviorTree::DSLStandardError).with_message(/should be a single node/)
      end
    end
  end
end
