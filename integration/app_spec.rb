require 'json'
require 'open-uri'
require 'socket'

describe 'Topten App' do

  before :all do
    run ('rm -rf integration.log')
  end


  def start_app
    # Start app.
    Thread.new do |t|
      run('bundle exec rake app >> integration.log 2>&1')
    end

    # Wait for it to be ready
    start = Time.now
    while (Time.now - start < 90) 
      return if (TCPSocket.open('localhost', port) rescue nil)
      sleep 1
    end
    fail "App failed to start"
  end

  def port
    Integer(ENV.fetch('PORT', '8000'))
  end

  def run(cmd)
    system(cmd)
    fail "Failed to execute command" unless $?.exitstatus.zero?
  end

  def top10
    JSON.parse(open('http://localhost:8000/top10').read)
  end

  def app_pid
    Integer(File.read('app.pid'))
  end

  # Wait for the app to die, fail if it doesn't.
  def wait_for_app_death
    start = Time.now

    # Wait longer than the backoff timeout
    while (Time.now - start < 90) 
      begin
        Process.getpgid(app_pid)
        sleep(1)
      rescue Errno::ESRCH 
        return
      end
    end
    fail "App failed to die"
  end

  describe '#/top10' do
    before :each do
      start_app
    end

    after :each do
      run('bundle exec rake quit')
      wait_for_app_death
    end

    it 'should return a json array' do
      expect(top10.class).to eq Array
    end

    it 'should still run after a hup' do
      run("bundle exec rake hup")
      expect(top10.class).to eq Array
    end
  end

  # Tests for each signal
  describe 'kill signals' do
    %w'quit int term'.each do |signal|
      it "kills the app with #{signal}" do
        start_app 
        run("bundle exec rake #{signal}")
        wait_for_app_death
      end
    end
  end
end
