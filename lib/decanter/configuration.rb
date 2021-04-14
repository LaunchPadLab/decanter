module Decanter
  class Configuration

    attr_accessor :strict, :log_unhandled_keys

    def initialize
      @strict = true
      @log_unhandled_keys = true
    end
  end
end
