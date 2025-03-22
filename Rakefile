# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]

namespace :wasm do
  ENV["BUNDLE_GEMFILE"] = File.expand_path("dist/gems.rb")

  desc "Build Ruby WASM and install gems"
  task :build do
    Dir.chdir("dist") do
      sh "bundle install"
    end

    Rake::Task["wasm:build_only"].invoke
  end

  desc "Build Ruby WASM"
  task :build_only do
    Dir.chdir("dist") do
      sh "bundle exec rbwasm build --ruby-version 3.4 -o ruby+wands.wasm"
    end
  end
end
