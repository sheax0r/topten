require 'webrick/httpserver'

module Topten
  class Server
    attr_reader :webrick_opts

    def initialize
      @webrick_opts = {
        :Port => Integer(ENV.fetch('PORT', 8000))
      }
    end

    def run
      WEBrick::HTTPServer.new(webrick_opts).tap do |server|
        server.start
      end
    end
  end
end
