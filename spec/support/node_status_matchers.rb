# frozen_string_literal: true

%i[success running failure].each do |expected_status|
  RSpec::Matchers.define "be_#{expected_status}".to_sym do
    match do |node|
      node.status.send("#{expected_status}?")
    end
    failure_message do |node|
      "status comparison failed #{node.status.to_sym} and #{expected_status}"
    end
  end
end

RSpec::Matchers.define :have_children_statuses do |expected_statuses|
  match do |node|
    children = node.instance_variable_get(:@children)

    unless expected_statuses.is_a?(Array)
      # If status is a single value, transform it into an array, that has the same value repeated
      # once per child.
      expected_statuses = Array.new(children.count, expected_statuses)
    end

    return false if expected_statuses.count != children.count

    children.each_with_index do |child, i|
      expected_status = expected_statuses[i]
      return false unless child.status.send("#{expected_status}?")
    end

    true
  end

  failure_message do |node|
    children = node.instance_variable_get(:@children)
    statuses = children.map { |child| child.status.to_sym }
    "status comparison failed #{statuses} and #{expected_statuses}"
  end
end
