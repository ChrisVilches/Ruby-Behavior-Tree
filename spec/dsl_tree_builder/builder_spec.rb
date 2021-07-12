# frozen_string_literal: true

describe BehaviorTree::Builder do
  # Is executed statically once.
  describe '.initial_config' do
    it 'aliases are all different to the original (otherwise it would not be an alias)' do
      node_type_mapping = described_class.instance_variable_get(:@node_type_mapping)

      node_type_mapping.each do |k, v|
        expect(v[:alias]).to_not eq k
      end
    end
  end

  # NOTE: Specs below are for per-instance registration (not implemented yet).
  #       These specs are fully working. But it's also necessary to test tree creation
  #       using .new (instance builder). Currently all specs are using the static method.
  #
  # describe '.register' do
  #   context 'new instance' do
  #     let(:instance) { described_class.new }
  #     let(:static_mapping) { described_class.instance_variable_get(:@node_type_mapping) }
  #     let(:instance_mapping) { instance.instance_variable_get(:@node_type_mapping) }
  #
  #     before { instance.register(:instance1_only, 'FakeClass', children: :multiple) }
  #     it { expect(static_mapping).to_not have_key :instance1_only }
  #     it { expect(instance_mapping).to have_key :instance1_only }
  #
  #     context 'yet another instance created' do
  #       let(:another_instance) { described_class.new }
  #       let(:another_instance_mapping) { another_instance.instance_variable_get(:@node_type_mapping) }
  #       before { another_instance.register(:instance2_only, 'SomeClass', children: :single) }
  #
  #       it { expect(static_mapping).to_not have_key :instance2_only }
  #       it { expect(instance_mapping).to_not have_key :instance2_only }
  #       it { expect(another_instance_mapping).to have_key :instance2_only }
  #       it { expect(another_instance_mapping).to_not have_key :instance1_only }
  #     end
  #   end
  # end
end
