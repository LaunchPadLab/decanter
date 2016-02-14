module Decanter
  module ValueParser
    class DateTimeParser < Base
      def self.parse(val, options = {})
        parse_format = options.fetch(:parse_format, '%m/%d/%Y')
        return val unless val.present?
        return val if val.is_a?(DateTime)
        ::Date.strptime(val, parse_format)
      end
    end
  end
end
