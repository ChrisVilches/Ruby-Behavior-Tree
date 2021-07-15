# frozen_string_literal: true

# Load all files from lib.
Dir[File.join(__dir__, 'behavior_tree', '**', '*.rb')].sort.each { |file| require_relative file }
