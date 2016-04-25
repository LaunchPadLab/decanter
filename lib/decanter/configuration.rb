module Decanter
  class Configuration

    attr_accessor :strict

    def initialize
      @strict = :with_exception
    end
  end
end
