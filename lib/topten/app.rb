require 'topten/server'
require 'topten/consumer'
require 'topten/log_helper'
require 'topten/hashtag_store'

module Topten
  class App
    include Topten::LogHelper
    attr_reader :server, :consumer, :tag_store

    def initialize
      @tag_store = HashtagStore.new
      @server = Server.new tag_store
      @consumer = Consumer.new tag_store
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
