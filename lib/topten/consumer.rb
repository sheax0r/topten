require 'forwardable'
require 'json'
require 'topten/hashtag_store'
require 'topten/log_helper'
require 'topten/oauth_helper'
require 'topten/twitter_stream'

module Topten

  class Consumer
    extend Forwardable
    include Topten::OAuthHelper
    include LogHelper

    attr_reader :tag_store, :twitter_stream

    # Forward state assignment to twitter stream
    def_delegators :twitter_stream, :state=

    def initialize(tag_store)
      @tag_store = tag_store
      @twitter_stream = TwitterStream.new
    end

    def run
      twitter_stream.run do |msg|
        json = JSON.parse msg, symbolize_names: true
        date = json[:created_at]
        if date
          date = DateTime.parse json[:created_at]
          json[:entities][:hashtags].each do |tag|
            tag_store.add(Hashtag.new(tag[:text], date))
          end
        end
      end
    end
  end

end
