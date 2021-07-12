# frozen_string_literal: true

describe BehaviorTree::Decorators::Inverter do
  let(:child) { BehaviorTree::Nop.new }
  subject { described_class.new child }

  # TODO: This doesn't test the entire behavior of tick!.
  #       I had commented out 'ensure_after_tick' (from DecoratorBase), which executes
  #       'status_map', which triggered an error, but this spec didn't detect it.
  #
  #       That error is now covered in 'rspec spec/dsl_tree_builder/root_node_has_inverter_spec.rb'
  #       but it'd be great to have it here too.

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
      it { is_expected.to be_success }
    end
  end

  describe '.halt!' do
    before { child.status.running! }
    before { subject.halt! }
    it { expect(child).to be_success }
    it { is_expected.to be_failure }
  end
end
