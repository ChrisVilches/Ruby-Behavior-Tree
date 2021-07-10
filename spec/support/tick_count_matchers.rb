# frozen_string_literal: true

RSpec::Matchers.define :have_children_ticked_times do |expected_times|
  match do |node|
    children = node.instance_variable_get(:@children)
    children.map(&:tick_count) == expected_times
  end

  failure_message do |node|
    actual_counts = node.instance_variable_get(:@children)
                        .map(&:tick_count)
    "tick count comparison failed. Actual: #{actual_counts}, expected: #{expected_times}"
  end
end
