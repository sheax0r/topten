require 'thread'
require 'topten/hashtag'
require 'topten/log_helper'

module Topten
  class HashtagStore
    include LogHelper

    def initialize()
      @tags = []
      @semaphore = Mutex.new
    end

    def add(hashtag)
      now = Time.now
      # Add the new tag, pop any tags older than 60 seconds off the top.
      @semaphore.synchronize do
        @tags << hashtag
        expire(@tags, now)
      end
      self
    end 

    def all
      now = Time.now
      @semaphore.synchronize do
        expire(@tags, Time.now)
        @tags.dup
      end
    end

    private
    def expire(tags, now)
      @tags.shift while @tags.first && (now - @tags.first.date.to_time > 60)
    end
  end

end
