module Topten
  class HashtagStore
    @tags = []

    def initialize
    end

    def add(hashtag)
      # Add the new tag, pop any tags older than 60 seconds off the top.
      tags << hashtag
      tags.shift while tags.first && tags.first.date < (hashtag.date + 60.seconds)
    end 
  end

  class Hashtag
    attr_reader :date, :tag
    def initialize(date, tag)
      @date = date
      @tag = tag
    end
  end
end
