$: << File.join(__dir__, 'lib')
require 'rspec/core/rake_task'

# Spec tests
RSpec::Core::RakeTask.new('spec')

# Integration tests
RSpec::Core::RakeTask.new(:integration) do |t|
  t.pattern = 'integration/*_spec.rb'
end

# Run the top10 app
task :app do
  File.write('app.pid', Process.pid)
  require 'topten/app'
  Topten::App.new.run
end

# Send signals via rake.
%i'hup quit int term kill'.each do |sym|
  task sym do
    signal(sym.to_s.upcase)
  end
end

# Get data from the running app
task :get do
  require 'json'
  require 'open-uri'
  puts JSON.pretty_generate JSON.parse(open('http://localhost:8000/top10').read)
end

# Send the given signal to the app process
def signal(str)
  pid = File.read('app.pid')
  system "kill -s #{str} #{pid}"  
end

task default: [:spec, :integration]
