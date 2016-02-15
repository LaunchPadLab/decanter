require_relative 'core'

module Decanter
  module ValueParser
    class Base
      include Core
      def self.inherited(subclass)
        ValueParser.register(subclass)
      end
    end
  end
end

