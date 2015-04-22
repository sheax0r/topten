require 'net/https'
require 'uri'
require 'yaml'
require 'json'
require 'topten/log_helper'
require 'topten/oauth_helper'

module Topten
  class TwitterStream
    include OAuthHelper

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
        response.read_body do |chunk|
          stream_buffer.concat chunk.split(//)
          loop do
            message = next_message(stream_buffer)
            if message
              yield message
            else 
              break
            end
          end
        end
      end
    end

    private

    # Parse the next message from the buffer.
    def next_message(stream_buffer)
      # Find the line break after the length header.
      # Bail if there isn't one in the current buffer.
      line_break = stream_buffer.index("\r")
      return nil if line_break.nil?

      # Trim "keep-alive" newlines
      while (line_break == 0) 
        stream_buffer = stream_buffer.drop 2
        line_break = stream_buffer.index("\r")
      end
      return nil if line_break.nil?

      # Get the length header.
      msg_length_string = stream_buffer[0..line_break-1].join
      msg_length = Integer(msg_length_string)

      # Bail if remaining buffer size is less than message length,
      # (include extra space for linebreak and length header).
      return nil if (stream_buffer.size - msg_length_string.size - 2) <= msg_length 

      # Extract the message
      msg_start = line_break + 2
      msg_end = msg_start + msg_length - 2
      msg = stream_buffer[msg_start..msg_end].join

      # Move the buffer along, return the message
      stream_buffer = stream_buffer.drop msg_end + 2
      msg
    end
  end
end
