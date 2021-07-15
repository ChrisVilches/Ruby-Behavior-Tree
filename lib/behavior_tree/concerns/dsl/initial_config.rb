# frozen_string_literal: true

require 'yaml'

module BehaviorTree
  module Dsl
    # Executes the initial registration of nodes.
    module InitialConfig
      def dsl_config
        @dsl_config ||= YAML.load_file(File.join(__dir__, 'dsl.yml'))['dsl']
      end

      def initial_config
        dsl_config['nodes'].each do |node|
          BehaviorTree::Builder.register(
            node['keyword'].to_sym,
            node['class_name'],
            children: node['children'].to_sym
          )
        end

        dsl_config['aliases'].each do |k, v|
          BehaviorTree::Builder.register_alias(k.to_sym, v.to_sym)
        end
      end
    end
  end
end
