module Topten
  # Essential hashtag info: date + name
  class Hashtag
    attr_reader :date, :name
    def initialize(name, date)
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
