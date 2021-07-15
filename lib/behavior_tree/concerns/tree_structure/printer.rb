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
        # Store which depth values must continue to display a vertical line.
        vertical_lines_continues = Set.new

        each_node(:depth_preorder).map do |node, depth, _global_idx, parent_node|
          # Parent's last child?
          last_child = node == parent_node.children.last

          last_child ? vertical_lines_continues.delete(depth) : vertical_lines_continues << depth

          space = (0...depth).map { |d| vertical_lines_continues.include?(d) ? '│ ' : '  ' }.join
          connector = last_child ? '└─' : '├─'

          "#{space}#{connector}#{class_simple_name(node)} #{status_string(node)} #{tick_count_string(node)}"
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

      # Copied from Rails' ActiveSupport.
      def snake_case(str)
        str.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .downcase
      end

      def class_simple_name(node)
        pretty_name snake_case(node.class.name.split('::').last)
      end

      # Changes the name of some classes (maps it to a better name).
      def pretty_name(name)
        case name
        when 'task_base'
          'task'
        else
          name
        end
      end
    end
  end
end
