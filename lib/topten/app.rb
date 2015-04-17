require 'topten/server'
require 'topten/consumer'
require 'topten/log_helper'

module Topten
  class App
    include Topten::LogHelper
    attr_reader :server, :consumer

    def initialize
      @server = Topten::Server.new
      @consumer = Topten::Consumer.new
    end

    def run
      Thread.new do 
        consumer.run
      end

      trap(:INT){ 
        Thread.new { 
          logger.info('INT received, exiting')
          exit!
        }.join
      }

      trap(:QUIT){ 
        Thread.new {
          logger.info('QUIT received, exiting gracefully')
          consumer.shutdown
          exit!
        }.join
      }

      trap(:HUP) {
        Thread.new {
          logger.info('HUP received, resetting consumer')
          consumer.reset
        }.join
      }

      server.run
    end
  end
end
