# frozen_string_literal: true

require "bundler/setup"
require "reek/rake/task"
require "rspec/core/rake_task"
require "rubocop/rake_task"

Reek::Rake::Task.new
RSpec::Core::RakeTask.new { |task| task.verbose = false }
RuboCop::RakeTask.new

desc "Run code quality checks"
task quality: %i[reek rubocop]

task default: %i[quality spec]
