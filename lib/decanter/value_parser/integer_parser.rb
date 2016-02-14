module Decanter
  module ValueParser
    class IntegerParser < Base
      REGEX = /(\d|[.])/
      def self.parse(val, options = {})
        return val unless val.present?
        return val if val.is_a?(Fixnum)
        return val.to_i if val.is_a?(Float)
        val.scan(REGEX).join.try(:to_i)
      end
    end
  end
end
