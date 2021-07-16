# frozen_string_literal: true

describe BehaviorTree::Builder do
  let(:tree) do
    described_class.build do
      sel do
        task ->(context, node) { node.status.failure! if context.nil? }
        task ->(context, node) { node.status.failure! if context.nil? && node.is_a?(BehaviorTree::Task) }
      end
    end
  end

  context 'when tasks were created using lambdas' do
    before { 3.times { tree.tick! } }
    it { expect(tree).to be_failure }
    it { expect(tree).to have_children_ticked_times [3] }
    it { expect(tree).to have_children_statuses :failure }
    it { expect(tree.children.first).to have_children_statuses %i[success success] } # Halted.
    it { expect(tree.children.first).to have_children_ticked_times [3, 3] }
  end
end
