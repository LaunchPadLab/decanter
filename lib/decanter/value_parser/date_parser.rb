module Decanter
  module ValueParser
    class DateParser < Base
      def self.parse(val, options = {})
        parse_format = options.fetch(:parse_format, '%m/%d/%Y')
        return input_value unless input_value.present?
        return input_value if input_value.is_a?(Date)
        ::Date.strptime(input_value, parse_format)
      end
    end
  end
end

