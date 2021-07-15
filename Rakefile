# frozen_string_literal: true

require 'rubocop/rake_task'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'bundler/setup'
require 'behavior_tree'
require 'io/console'

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

# Utils for the visualize Rake task.
# NOTE: Don't use it for anything other than the Rake task.
class VisualizeUtils
  class << self
    def random_seed
      @random_seed ||= if ENV['random_seed'].nil?
                         (Time.now.to_f * 1000).to_i ^ Process.pid
                       else
                         ENV['random_seed'].to_i
                       end
    end

    def sleep_time
      result = ENV['sleep'].nil? ? 0.5 : ENV['sleep'].to_f
      raise 'Sleep time must be a positive float value' if result <= 0

      result
    end

    def print_random_seed_info
      puts ''
      puts "Generate the same tree by adding: random_seed=#{random_seed}"
    end

    def random_tree
      @random_tree ||= BehaviorTree::Builder.build_random_tree(recursion_amount: 2)
    end

    def update_and_draw
      $stdout.clear_screen
      random_tree.print
      print_random_seed_info
      random_tree.tick!
    end

    def setup_console
      srand(random_seed)
      $stdout.sync = true
      $stdout.clear_screen

      trap 'INT' do
        puts ''
        exit 0
      end
    end
  end
end

namespace :visualize do
  desc 'Visualize a random tree animated (optional parameters sleep=0.5 random_seed=12345678)'
  task :auto do
    VisualizeUtils.setup_console
    loop do
      VisualizeUtils.update_and_draw
      sleep VisualizeUtils.sleep_time
    end
  end

  desc 'Visualize a random tree, press key to tick (optional parameter random_seed=12345678)'
  task :manual do
    VisualizeUtils.setup_console
    loop do
      VisualizeUtils.update_and_draw
      puts 'Press Enter key to tick. Press CTRL+C (SIGINT) to exit.'
      $stdin.getc
    end
  end
end
