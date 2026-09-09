# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Run RuboCop linter"
task :rubocop do
  sh "bundle exec rubocop"
end

desc "Run CI checks (RSpec, RuboCop, Reek, Flay, and Bundler Audit)"
task :ci do
  sh "bin/ci"
end

task default: :spec
