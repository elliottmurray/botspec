require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'Generate change log'
task :generate_changelog do
  require 'conventional_changelog'
  require 'botspec/version'
  ConventionalChangelog::Generator.new.generate! version: "v#{Botspec::VERSION}"
end

task :console do
  exec "irb -r botspec -I ./lib"
end
