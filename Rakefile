# frozen_string_literal: true

require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: %i[lint spec]

desc 'Run RuboCop'
RuboCop::RakeTask.new(:lint) do |task|
  task.options = ['--fail-level', 'autocorrect']
end

desc 'Build and install locally'
task :install do
  temp_file = 'temp_file.delete_me.gem'
  `gem build --output=#{temp_file}`
  puts `gem install #{temp_file}`
  `rm #{temp_file}`
end
