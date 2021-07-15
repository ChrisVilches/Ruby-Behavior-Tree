# frozen_string_literal: true

# Load all files from lib.
Dir[File.join('./lib', 'behavior_tree', '**', '*.rb')].sort.each { |file| require file }
