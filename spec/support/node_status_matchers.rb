# frozen_string_literal: true

def node_status_comparison_fail_message(actual, expected_status)
  "status comparison failed. Actual: #{actual}, expected: #{expected_status}"
end

%i[success running failure].each do |expected_status|
  RSpec::Matchers.define "be_#{expected_status}".to_sym do
    match do |node|
      node.status.send("#{expected_status}?")
    end
    failure_message do |node|
      node_status_comparison_fail_message(node.status.to_sym, expected_status)
    end
  end
end

RSpec::Matchers.define :have_children_statuses do |expected_statuses|
  match do |node|
    children = node.children

    # If single value N, transform into [N, N, N, ...]
    expected_statuses = [expected_statuses] * children.count unless expected_statuses.is_a?(Array)

    expected_statuses == children.map { |child| child.status.to_sym }
  end

  failure_message do |node|
    statuses = node.children
                   .map { |child| child.status.to_sym }
    node_status_comparison_fail_message(statuses, expected_statuses)
  end
end
