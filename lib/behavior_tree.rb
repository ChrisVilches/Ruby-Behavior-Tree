# frozen_string_literal: true

# Load all files from lib.
# Gem.find_files('behavior_tree/**/*.rb').each { |path| require path }

Dir.glob(File.join('./lib', '**', '*.rb')).sort.each { |file| require file }
