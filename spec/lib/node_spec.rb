# frozen_string_literal: true

describe BehaviorTree.const_get(:Node) do
  subject { described_class.new }
  it { expect(subject).to respond_to :tick! }
  it { expect(subject).to respond_to :halt! }
end
