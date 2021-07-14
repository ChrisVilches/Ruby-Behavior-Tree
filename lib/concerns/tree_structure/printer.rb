# frozen_string_literal: true

require 'colorized_string'

module BehaviorTree
  module TreeStructure
    # Algorithm to print tree.
    module Printer
      def print
        each_node(:depth_preorder) do |node, depth|
          space = (0...depth).map { '  ' }.join
          node_alias = class_simple_name node.class
          puts "#{space}#{node_alias} #{status_string(node)} #{tick_count_string(node)}"
        end
      end

      private

      def status_string(node)
        if node.status.success?
          ColorizedString['success'].colorize(:blue)
        elsif node.status.running?
          ColorizedString['running'].colorize(:light_green)
        elsif node.status.failure?
          ColorizedString['failure'].colorize(:red)
        end
      end

      def tick_count_string(node)
        count = node.tick_count
        color = count.zero? ? :light_red : :light_black
        ColorizedString["(#{node.tick_count} ticks)"].colorize(color)
      end

      def snake_case(str)
        str.gsub(/([a-z])([A-Z])/) { "#{Regexp.last_match(1)}_#{Regexp.last_match(2)}" }.downcase
      end

      def class_simple_name(constant)
        snake_case(constant.name.split('::').last)
      end
    end
  end
end
