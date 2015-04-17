require 'json'
require 'topten/log_helper'
require 'topten/hashtag_store'

module Topten
  include LogHelper
  include Topten::OAuthHelper

  class Consumer

    attr_reader :tag_store

    def initialize(tag_store)
      @tag_store = tag_store
    end

    def run
      twitter_stream.new.run do |msg|
        json = JSON.parse msg, symbolize_names: true
        date = DateTime.parse json[:created_at] 
        json[:hashtags].each do |value|
          hashtag_store.add(Hashtag.new(date, value))
        end
      end
    end

    def reset
    end

    def shutdown
    end
  end
end

