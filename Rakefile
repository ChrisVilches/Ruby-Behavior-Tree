# frozen_string_literal: true

require 'rubocop/rake_task'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: %i[lint spec]

desc 'Run RuboCop'
RuboCop::RakeTask.new(:lint) do |task|
  task.options = ['--fail-level', 'autocorrect']
end

desc 'Run RuboCop for specs'
RuboCop::RakeTask.new(:spec_lint) do |task|
  task.requires << 'rubocop-rspec'
end

desc 'Visualize a random tree animated (optional parameters sleep=0.5 random_seed=12345678)'
task :visualize do
  require 'bundler/setup'
  require 'behavior_tree'
  require 'io/console'

  sleep_time = ENV['sleep'].nil? ? 0.5 : ENV['sleep'].to_f

  srand(ENV['random_seed'].to_i) unless ENV['random_seed'].nil?

  raise 'Sleep time must be a positive float value' if sleep_time <= 0

  tree = BehaviorTree::Builder.build_random_tree(recursion_amount: 2)

  $stdout.sync = true

  loop do
    $stdout.clear_screen
    tree.print
    sleep sleep_time
    tree.tick!
  end
end
