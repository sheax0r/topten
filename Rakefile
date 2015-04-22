$: << File.join(__dir__, 'lib')
require 'rspec/core/rake_task'

# Spec tests
RSpec::Core::RakeTask.new('spec')

# Integration tests
RSpec::Core::RakeTask.new(:integration) do |t|
  t.pattern = 'integration/*/_spec.rb'
end

# PoC of twitter stream: Print out twitter status updates forever.
task :sample do
  require 'net/https'
  require 'json'
  require 'topten/twitter_stream'
  Topten::TwitterStream.new.run do |msg|
    puts JSON.parse msg
  end
end

# Run the top10 app
task :app do
  require 'topten/app'
  Topten::App.new.run
end

task default: :spec


