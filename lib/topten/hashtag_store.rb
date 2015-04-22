require 'thread'
require 'topten/log_helper'

module Topten
  class HashtagStore
    include LogHelper

    def initialize
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
    end 

    def all
      @semaphore.synchronize do
        @tags.dup
      end
    end

    def expire(tags, now)
      @tags.shift while @tags.first && (now - @tags.first.date.to_time > 60)
    end
  end

  class Hashtag
    attr_reader :date, :name
    def initialize(date, name)
      @date = date
      @name = name
    end
  end
end
