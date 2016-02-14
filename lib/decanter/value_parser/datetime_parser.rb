module Decanter
  module ValueParser
    class DateTimeParser < Base
      parser do |val, options|
        parse_format = options.fetch(:parse_format, '%m/%d/%Y')
        return val if val.is_a?(DateTime)
        ::Date.strptime(val, parse_format)
      end
    end
  end
end
