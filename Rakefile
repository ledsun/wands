# frozen_string_literal: true

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]

namespace :wasm do
  desc "Build Ruby WASM and install gems"
  task :build do
    Dir.chdir("dist") do
      ENV["BUNDLE_GEMFILE"] = File.expand_path("gems.rb")
      sh "bundle install"
      sh "bundle exec rbwasm build --ruby-version 3.4 -o ruby+wands.wasm"
      sh "cp ruby+wands.wasm ../examples/ruby_wasm/dist"
    end
  end

  desc "Test Ruby WASM in Node.js"
  task :test do
    Dir.chdir("node_wasi_test") do
      sh "npm install"
      sh "npm test"
    end
  end
end
