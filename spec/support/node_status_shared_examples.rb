# frozen_string_literal: true

shared_examples 'status is success' do
  it { expect(subject.status.success?).to be true }
end

shared_examples 'status is running' do
  it { expect(subject.status.running?).to be true }
end

shared_examples 'status is failure' do
  it { expect(subject.status.failure?).to be true }
end

shared_examples 'all children have success status' do
  it do
    all_success = subject.instance_variable_get(:@children)
                         .map { |child| child.status.success? }
                         .all?(true)
    expect(all_success).to be true
  end
end

shared_examples 'all children have running status' do
  it do
    all_running = subject.instance_variable_get(:@children)
                         .map { |child| child.status.running? }
                         .all?(true)
    expect(all_running).to be true
  end
end

shared_examples 'all children have failure status' do
  it do
    all_failure = subject.instance_variable_get(:@children)
                         .map { |child| child.status.failure? }
                         .all?(true)
    expect(all_failure).to be true
  end
end
