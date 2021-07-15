# frozen_string_literal: true

# Load all files from lib.
# Gem.find_files('behavior_tree/**/*.rb').each { |path| require path }

# Dir.glob(File.join('**', '*.rb')).sort.each { |file| require_relative file }

# Dir[File.join('.', 'behavior_tree', '**', '*.rb')].sort.each { |file| require_relative file }

# pp Dir[File.join('.', 'behavior_tree', '**', '*.rb')]
# require_relative './behavior_tree/tree'

require_relative './behavior_tree/concerns/tree_structure/printer'
require_relative './behavior_tree/concerns/tree_structure/algorithms'
require_relative './behavior_tree/tasks/task_base'
require_relative './behavior_tree/single_child_node'
require_relative './behavior_tree/decorator_nodes/decorator_base'
require_relative './behavior_tree/decorator_nodes/repeater'
require_relative './behavior_tree/decorator_nodes/retry'
require_relative './behavior_tree/decorator_nodes/inverter'
require_relative './behavior_tree/decorator_nodes/force_success'
require_relative './behavior_tree/decorator_nodes/force_failure'
require_relative './behavior_tree/decorator_nodes/condition'
require_relative './behavior_tree/errors'
require_relative './behavior_tree/control_nodes/control_node_base'
require_relative './behavior_tree/control_nodes/selector'
require_relative './behavior_tree/control_nodes/sequence'
require_relative './behavior_tree/node_status'
require_relative './behavior_tree/tasks/nop'
require_relative './behavior_tree/builder'
require_relative './behavior_tree/version'
require_relative './behavior_tree/tree'
