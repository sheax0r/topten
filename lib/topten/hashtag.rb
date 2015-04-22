module Topten
  class Hashtag
    attr_reader :date, :name
    def initialize(date, name)
      @date = date
      @name = name
    end

    def ==(other)
      other.is_a?(Hashtag) && name == other.name && date == other.date
    end

    def hash
      name.hash ^ date.hash
    end
  end
end
