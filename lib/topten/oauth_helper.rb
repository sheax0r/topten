require 'oauth'

module Topten
  # Makes oauth easy
  module OAuthHelper
    def sign_request(req, params)
      consumer = OAuth::Consumer.new(
        params.fetch(:consumer_key),
        params.fetch(:consumer_secret),
        site: 'https://stream.twitter.com',
        scheme: :header)

      # now create the access token object from passed values
      token_hash = { oauth_token: params.fetch(:access_token),
                     oauth_token_secret: params.fetch(:access_token_secret) }
      access_token = OAuth::AccessToken.from_hash(consumer, token_hash)

      access_token.sign!(req)
    end
  end
end
