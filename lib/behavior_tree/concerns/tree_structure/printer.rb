# frozen_string_literal: true

require 'colorized_string'

module BehaviorTree
  module TreeStructure
    # Algorithm to print tree.
    module Printer
      def print
        puts to_s
      end

      def to_s
        lines = []
        lines << '∅' # Style for the root node.
        lines += tree_lines
        lines << ''
        lines << cycle_string
        lines << uniq_nodes_string
        lines << size_string
        lines << tree_tick_count_string
        lines.join "\n"
      end

      private

      def tree_lines
        # Store which depth values must continue to display a vertical line.
        vertical_lines_continues = Set.new

        each_node(:depth_preorder).map do |node, depth, _global_idx, parent_node|
          # Parent's last child?
          last_child = node == parent_node.children.last

          last_child ? vertical_lines_continues.delete(depth) : vertical_lines_continues << depth

          space = (0...depth).map { |d| vertical_lines_continues.include?(d) ? '│     ' : '      ' }.join
          connector = last_child ? '└─' : '├─'

          "#{space}#{connector}#{resolve_display_name(node)} #{status_string(node)} #{tick_count_string(node)}"
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

      def tree_tick_count_string
        "Tree has been ticked #{tick_count} times."
      end

      # Copied from Rails' ActiveSupport.
      def snake_case(str)
        str.gsub(/::/, '/')
           .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .tr('-', '_')
           .downcase
      end

      def resolve_display_name(node)
        if node.respond_to?(:display_name)
          node.display_name
        else
          snake_case(node.class.name.split('::').last)
        end
      end
    end
  end
end
