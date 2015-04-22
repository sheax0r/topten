require 'webrick/httpserver'
require 'json'

module Topten
  class Server
    attr_reader :tag_store

    def initialize(tag_store)
      @tag_store = tag_store 
    end

    def run
      WEBrick::HTTPServer.new(webrick_opts).tap do |server|
        server.mount_proc('/top10') do |request, response|
          response.status = 200
          response['Content-Type'] = 'application/json'
          response.body = topten.to_json
        end
        server.start
      end
    end

    private

    def topten
      tags = tag_store.all.map(&:name)
      freq = tags.inject(Hash.new(0)) { |h,v| h[v] += 1; h }
      freq.to_a.sort_by{ |f| f[1] }[0..9].map{ |f| f[0] }
    end

    def webrick_opts
      {
        :Port => Integer(ENV.fetch('PORT', 8000))
      }
    end
  end
end
