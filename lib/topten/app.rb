require 'topten/server'
require 'topten/consumer'
require 'topten/log_helper'
require 'topten/hashtag_store'
require 'thread'

module Topten
  class App
    include Topten::LogHelper
    attr_reader :server, :consumer, :tag_store

    def initialize
      @semaphore = Mutex.new
      @tag_store = HashtagStore.new
      @server = Server.new tag_store
      @consumer = Consumer.new tag_store
    end

    def run
      @semaphore.synchronize do
        @consumer_thread = Thread.new do
          consumer.run
        end
      end

      [:INT, :TERM].each do |sym|
        trap(sym){ 
          Thread.new { 
            # Hard exit
            logger.info("#{sym} received, exiting")
            exit!
          }.join
        }
      end

      trap(:QUIT){ 
        # Soft exit: Set consumer state to terminated and wait for it to finish.
        Thread.new {
          logger.info('QUIT received, exiting gracefully')
          consumer.state = :terminated
        }.join
        Thread.new {
          @consumer_thread.join
          exit!
        }
      }

      trap(:HUP) {
        Thread.new {
          @semaphore.synchronize do 
            logger.info('HUP received, resetting statistics and stream')
            consumer.state = :terminated
          end
        }.join

        Thread.new {
          @semaphore.synchronize do
            # Wait for current consumer to finish.
            @consumer_thread.join

            # Reset statistics
            tag_store.reset

            # Restart consumer.
            @consumer = Consumer.new tag_store
            @consumer_thread = Thread.new do
              consumer.run
            end
          end
        }
      }

      # Start 'er up.
      server.run
    end
  end
end
