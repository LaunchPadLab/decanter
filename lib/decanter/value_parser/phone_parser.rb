module Decanter
  module ValueParser
    class PhoneParser < Base
      REGEX = /(\d|[.])/
      def self.parse(val, options = {})
        return val unless val.present?
        return val if val.is_a?(Fixnum)
        val.scan(REGEX).join.try(:to_s)
      end
    end
  end
end
