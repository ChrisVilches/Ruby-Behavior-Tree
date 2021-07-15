# frozen_string_literal: true

describe BehaviorTree::Decorators::ForceFailure do
  subject { described_class.new child }

  let(:child) { BehaviorTree::Nop.new }

  describe '.halt!' do
    before { child.status.running! }

    before { subject.halt! }

    it { is_expected.to be_failure }
    it { expect(child).to be_success }
  end

  describe '.status_map' do
    before { child.status.send("#{child_returned_status}!") }

    before { subject.send :status_map }

    context 'child returns running' do
      let(:child_returned_status) { :running }

      it { is_expected.to be_running }
    end

    context 'child returns success' do
      let(:child_returned_status) { :success }

      it { is_expected.to be_failure }
    end

    context 'child returns failure' do
      let(:child_returned_status) { :failure }

      it { is_expected.to be_failure }
    end
  end

  describe '.halt!' do
    before { child.status.running! }

    before { subject.halt! }

    it { expect(child).to be_success }
    it { is_expected.to be_failure }
  end
end
