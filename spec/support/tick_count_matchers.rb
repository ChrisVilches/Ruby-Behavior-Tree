# frozen_string_literal: true

RSpec::Matchers.define :have_children_ticked_times do |expected_times|
  # @children is for control-flow nodes, and @child is for decorators.

  match do |node|
    children = node.instance_variable_get(:@children) || [node.instance_variable_get(:@child)]
    children.map(&:tick_count) == expected_times
  end

  failure_message do |node|
    children = node.instance_variable_get(:@children) || [node.instance_variable_get(:@child)]
    actual_counts = children.map(&:tick_count)
    "tick count comparison failed. Actual: #{actual_counts}, expected: #{expected_times}"
  end
end
