# frozen_string_literal: true

# Load all files from lib.
Dir[File.join(__dir__, 'lib', '**', '*.rb')].sort.each { |file| require file }
