# frozen_string_literal: true

# Load all files from lib.
Dir[File.join(__dir__, 'lib', '**', '*.rb')].each { |file| require file }
