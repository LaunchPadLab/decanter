module Decanter
  module ValueParser
    class FloatParser < Base
      REGEX = /(\d|[.])/
      def self.parse(val, options = {})
        return val unless val.present?
        return val if ["Float", "Fixnum"].include?(val.class.name)
        val.scan(REGEX).join.try(:to_f)
      end
    end
  end
end
