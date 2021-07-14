# frozen_string_literal: true

require 'colorized_string'

module BehaviorTree
  module TreeStructure
    # Algorithm to print tree.
    module Printer
      def print
        puts '∅' # Style for the root node.
        tree_lines.each { |line| puts line }
        puts ''
        puts cycle_string
        puts uniq_nodes_string
        puts size_string
      end

      private

      def tree_lines
        depth_last_child = Set.new
        prev_depth = 0

        each_node(:depth_preorder).map do |node, depth, _global_idx, local_idx, local_count|
          # Parent's last child?
          last_child = local_idx == local_count - 1

          update_depth_last_child(prev_depth, depth, depth_last_child, last_child)

          prev_depth = depth

          tree_line(node, last_child, depth, depth_last_child)
        end
      end

      # TODO: Comment and explain.
      def tree_line(node, last_child, curr_depth, depth_last_child)
        space = (0...curr_depth).map { |d| depth_last_child.include?(d) ? '  ' : '│ ' }.join
        connector = last_child ? '└─' : '├─'

        depth_debug = (0...curr_depth).map { |d| depth_last_child.include?(d) ? 'x' : '_' }.join

        "#{space}#{connector}#{class_simple_name(node)} #{status_string(node)} #{tick_count_string(node)} -- #{depth_debug}"
      end

      # TODO: Comment and explain because it's a bit hard.
      def update_depth_last_child(prev_depth, curr_depth, depth_last_child, last_child)
        if last_child
          depth_last_child << curr_depth
        elsif prev_depth < curr_depth
          depth_last_child.delete curr_depth
        end
      end

      def size_string
        "Tree has #{size - 1} nodes."
      end

      def cycle_string
        "Cycles: #{bool_yes_no(cycle?)}."
      end

      def uniq_nodes_string
        "All nodes are unique object refs: #{bool_yes_no(uniq_nodes?)}."
      end

      def bool_yes_no(bool)
        bool ? 'yes' : 'no'
      end

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

      # Copied from Rails' ActiveSupport.
      def underscore(str)
        str.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .downcase
      end

      def class_simple_name(node)
        snake_case(node.class.name.split('::').last)
      end
    end
  end
end
