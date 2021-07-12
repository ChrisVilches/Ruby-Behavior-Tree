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
end
