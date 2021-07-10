# frozen_string_literal: true

module BehaviorTree
  # A node (abstract class).
  class Node
    attr_reader :status

    def initialize
      @status = NodeStatus.new NodeStatus::SUCCESS
    end

    def tick!
      raise NotImplementedError
    end

    def halt!
      raise NotImplementedError
    end
  end

  # TODO: Set as private. Can be done but Rspec fails.
  # private_constant :Node
end
