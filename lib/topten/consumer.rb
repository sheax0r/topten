require 'json'
require 'topten/hashtag_store'
require 'topten/log_helper'
require 'topten/oauth_helper'
require 'topten/twitter_stream'

module Topten
  include LogHelper
  include Topten::OAuthHelper

  class Consumer
    include LogHelper

    attr_reader :tag_store

    def initialize(tag_store)
      @tag_store = tag_store
    end

    def run
      TwitterStream.new.run do |msg|
        begin
          json = JSON.parse msg, symbolize_names: true
          date = json[:created_at]
          if date
            date = DateTime.parse json[:created_at]
            json[:entities][:hashtags].each do |tag|
              tag_store.add(Hashtag.new(date, tag[:text]))
            end
          end
        end
      end
    end

    def reset
    end

    def shutdown
    end
  end
end
