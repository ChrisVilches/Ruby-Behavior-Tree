# frozen_string_literal: true

RSpec::Matchers.define :have_children_ticked_times do |expected_times|
  # @children is for control nodes, and @child is for decorators.

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

RSpec::Matchers.define :have_been_running_for_ticks do |expected_times|
  match do |node|
    node.instance_variable_get(:@ticks_running) == expected_times
  end

  failure_message do |node|
    actual_counts = node.instance_variable_get(:@ticks_running)
    "tick count comparison failed. Actual: #{actual_counts}, expected: #{expected_times}"
  end
end
