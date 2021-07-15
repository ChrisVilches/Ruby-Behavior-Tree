# frozen_string_literal: true

require_relative 'lib/behavior_tree/version'

Gem::Specification.new do |spec|
  spec.name          = 'behavior_tree' # TODO: Change?
  spec.version       = BehaviorTree::VERSION
  spec.authors       = ['Felo Vilches']
  spec.email         = ['felovilches@gmail.com']

  spec.summary       = 'Behavior Tree (AI) library for Ruby.'
  spec.homepage      = 'https://github.com/FeloVilches/Ruby-Behavior-Tree' # TODO: Change?
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')

  # spec.metadata['allowed_push_host'] = 'TODO: Set to 'http://mygemserver.com''
  # spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = 'TODO: Put your gem's public repo URL here.'
  # spec.metadata['changelog_uri'] = 'TODO: Put your gem's CHANGELOG.md URL here.'

  spec.files         = Dir[File.join(__dir__, 'lib', '**', '*')]
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'colorize', '~> 0.8.1'
end