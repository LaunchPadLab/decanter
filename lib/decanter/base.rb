require 'decanter/core'

module Decanter
  class Base
    include Core
    def self.inherited(subclass)
      Decanter.register(subclass)
    end
  end
end
