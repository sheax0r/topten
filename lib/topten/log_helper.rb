require 'logger'

module Topten
  # Makes logging easy
  module LogHelper
    def logger
      Logger.new(STDOUT).tap do |logger|
        logger.level = Logger.const_get(ENV.fetch('LOG_LEVEL', 'INFO'))
      end
    end
  end
end
