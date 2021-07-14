# frozen_string_literal: true

describe BehaviorTree::Builder do
  subject do
    BehaviorTree::Builder.build do
      inverter do
        t { status.success! }
      end
    end
  end

  # Decompose the tree.
  let(:inverter) { subject.children.first }
  let(:task) { inverter.children.first }

  context 'tree with inverter and task' do
    before { subject.tick! }
    it { is_expected.to be_instance_of BehaviorTree::Tree }
    it { expect(subject.size).to eq 3 }

    it { expect(subject.tick_count).to eq 1 }
    it { expect(inverter.tick_count).to eq 1 }
    it { expect(task.tick_count).to eq 1 }

    it { expect(task).to be_success }
    it { expect(inverter).to be_failure }
    it { is_expected.to be_failure }
  end
end
