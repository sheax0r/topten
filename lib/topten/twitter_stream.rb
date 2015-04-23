require 'net/https'
require 'uri'
require 'yaml'
require 'topten/log_helper'
require 'topten/oauth_helper'

module Topten
  class TwitterStream
    include OAuthHelper
    include LogHelper

    def initialize
      @state = :pending
      @semaphore = Mutex.new
    end

    def run(&block)
      uri = URI.parse('https://stream.twitter.com/1.1/statuses/sample.json')
      uri.query = URI.encode_www_form(delimited: 'length')

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      request = Net::HTTP::Get.new(uri.request_uri)
      sign_request(request, YAML.load(File.read('oauth.yml')))

      stream_buffer = []
      http.request(request) do |response|
        if Integer(response.code) == 420
          logger.info("Rate limited. Sleeping for 60 seconds...")
          sleep(60)
          raise Retry 
        end
        response.read_body do |chunk|
          stream_buffer.concat chunk.split(//)
          while (message = next_message stream_buffer)
            if state == :terminated
              http.finish
              break
            else
              yield message
            end
          end
        end
      end
    rescue Retry
      retry
    rescue Zlib::BufError
      # TODO: Figure out if there's a way to stop this from happening.
      # We appear to always get a BufError after calling http.finish.
      # For now, catch it and ignore it.
    end

    # Parse the next message from the buffer.
    def next_message(stream_buffer)
      # Trim newlines
      while stream_buffer[0..1].join == "\r\n"
        stream_buffer.shift 2
      end

      # Find the line break after the length header.
      # Bail if there isn't one in the current buffer.
      line_break = stream_buffer.index("\r")
      return nil if line_break.nil?

      # Get the length header.
      msg_length_string = stream_buffer[0..line_break-1].join
      msg_length = Integer(msg_length_string)

      # Bail if remaining buffer size is less than message length,
      # (include extra space for linebreak and length header).
      return nil if (stream_buffer.size - msg_length_string.size - 2) < msg_length 

      # Extract the message
      msg_start = line_break + 2
      msg_end = msg_start + msg_length - 1
      msg = stream_buffer[msg_start..msg_end].join

      # Move the buffer along, return the message
      stream_buffer.shift msg_end + 1
      msg
    end

    def state=(state)
      @semaphore.synchronize do
        @state = state
      end
    end

    def state
      @semaphore.synchronize do
        @state
      end
    end

    class Retry < StandardError; end
  end
end
