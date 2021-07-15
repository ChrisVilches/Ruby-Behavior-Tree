# frozen_string_literal: true

module CustomControlNodes
  class TickOnlySecondNode < BehaviorTree::ControlNodeBase
    children_traversal_strategy :only_middle

    private

    def only_middle
      Enumerator.new do |y|
        y << @children[1]
      end
    end

    def on_tick
      tick_each_children do
        status.success!
      end
    end
  end

  class CustomRunningTask < BehaviorTree::Task
    def on_tick
      context[:a] ||= 0
      context[:a] += 1
      status.running!
    end
  end
end

describe BehaviorTree::Builder do
  subject { tree }

  let(:tree) do
    described_class.build do
      tick_only_second_node do
        t { context[:a] += 1 }
        t { context[:b] += 1 }
        t { context[:c] += 1 }
      end
    end
  end

  before { tree.context = { a: 0, b: 0, c: 0 } }

  describe '.register' do
    context 'a new control node' do
      before :all do
        described_class.register(
          :tick_only_second_node,
          'CustomControlNodes::TickOnlySecondNode',
          children: :multiple
        )
      end

      before { 5.times { subject.tick! } }

      it { expect(tree.context).to eq({ a: 0, b: 5, c: 0 }) }

      context 'when registering alias for custom node' do
        before { described_class.register_alias(:tick_only_second_node, :tick_only_second_node_alias) }
        it do
          mapping = described_class.instance_variable_get :@node_type_mapping
          expect(mapping[:tick_only_second_node][:alias]).to eq :tick_only_second_node_alias
          expect(mapping[:tick_only_second_node_alias][:alias]).to eq :tick_only_second_node
        end
      end
    end

    context 'already existing node' do
      it do
        expect do
          described_class.register(:inv, Array, children: :single)
        end.to raise_error BehaviorTree::RegisterDSLNodeAlreadyExistsError
      end
    end

    context 'when a custom task is registered' do
      before :all do
        described_class.register(
          :custom_running,
          'CustomControlNodes::CustomRunningTask',
          children: :none
        )
      end

      let(:tree1) { described_class.build { custom_running } }
      let(:tree2) { described_class.build { sel { custom_running } } }

      before do
        tree2.context = {}
        100.times { tree2.tick! }
      end

      it { expect { tree1 }.not_to raise_error }
      it { expect { tree2 }.not_to raise_error }
      it { expect(tree2).to be_running }
      it { expect(tree2.context[:a]).to eq 100 }
    end
  end

  describe '.register_alias' do
    context 'original key does not exist' do
      it { expect { described_class.register_alias(:not_exists, :alias) }.to raise_error RuntimeError }
    end

    context 'original key exists' do
      before { described_class.register_alias(:force_success, :always_succeed) }

      it do
        mapping = described_class.instance_variable_get :@node_type_mapping
        expect(mapping[:always_succeed][:alias]).to eq :force_success
        expect(mapping[:force_success][:alias]).to eq :always_succeed
      end
    end
  end

  describe '.respond_to_missing?' do
    context 'key has not been added' do
      it { expect(described_class).not_to respond_to :always_fail }
    end

    context 'key has been added' do
      before { described_class.register_alias(:force_failure, :always_fail) }

      it { expect(described_class).to respond_to :always_fail }
    end
  end
end
