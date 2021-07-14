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
