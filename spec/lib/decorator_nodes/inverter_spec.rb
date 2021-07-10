# frozen_string_literal: true

describe BehaviorTree::Decorators::Inverter do
  subject { described_class.new BehaviorTree::Nop.new }
  before { subject.instance_variable_get(:@child).status.send("#{child_returned_status}!") }
  before { subject.decorate }

  describe '.decorate' do
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
      it { is_expected.to be_success }
    end
  end
end
