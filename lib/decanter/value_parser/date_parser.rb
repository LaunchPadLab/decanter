module Decanter
  module ValueParser
    class DateParser < Base

      allow Date

      parser do |name, val, options|
        parse_format = options.fetch(:parse_format, '%m/%d/%Y')
        ::Date.strptime(val, parse_format)
      end
    end
  end
end

