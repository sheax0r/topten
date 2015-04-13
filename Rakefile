require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

# Spec tests
RSpec::Core::RakeTask.new('spec')

# Integration tests
RSpec::Core::RakeTask.new(:integration) do |t|
  t.pattern = 'integration/*/_spec.rb'
end

task default: :spec
