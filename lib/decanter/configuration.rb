# frozen_string_literal: true

module Decanter
  class Configuration
    attr_accessor :strict

    def initialize
      @strict = :with_exception
    end
  end
end
