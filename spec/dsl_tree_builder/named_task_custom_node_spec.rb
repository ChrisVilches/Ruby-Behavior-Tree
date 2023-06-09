# frozen_string_literal: true

module TestNodes
  class NamedTask < BehaviorTree::Task
    def initialize(name, &block)
      super(nil, &block)
      @name = name
    end

    def display_name
      @name
    end

    def on_tick
      super
      status.success!
    end
  end
end

describe BehaviorTree::Builder do
  subject { tree }

  let(:tree) do
    described_class.build do
      inverter do
        seq do
          named_task 'small-increase' do
            context[:num] += 67
          end
          named_task 'large-increase' do
            context[:num] += 10_000
          end
        end
      end
    end
  end

  before { tree.context = { num: 0 } }

  before :all do
    described_class.register(
      :named_task,
      'TestNodes::NamedTask',
      children: :none
    )
  end

  before { tree.tick! }

  context 'runs all tasks correctly' do
    it do
      expect(tree.context[:num]).to eq 10_067
    end
  end

  context 'prints the tree correctly' do
    it do
      lines = tree.to_s.split("\n")
      expect(lines[0]).to include '∅'

      expect(lines[1]).to include '└─inverter'
      expect(lines[2]).to include '      └─sequence'
      expect(lines[3]).to include '            ├─small-increase'
      expect(lines[4]).to include '            └─large-increase'

      expect(lines[1]).to include 'failure'
      expect(lines[2]).to include 'success'
      expect(lines[3]).to include 'success'
      expect(lines[4]).to include 'success'
    end
  end
end
