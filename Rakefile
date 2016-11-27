require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: :test

desc 'Run acceptance tests (RSpec + Rubocop)'
task test: 'acceptance'

desc 'Run acceptance tests (RSpec + Rubocop)'
task :acceptance do |_t|
  Rake::Task['spec'].invoke
  Rake::Task['rubocop'].invoke
end
