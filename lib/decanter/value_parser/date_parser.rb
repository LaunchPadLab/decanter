module Decanter
  module ValueParser
    class DateParser < Base

      allow :date

      parser do |val, options|
        parse_format = options.fetch(:parse_format, '%m/%d/%Y')
        return val if val.is_a?(Date)
        ::Date.strptime(val, parse_format)
      end
    end
  end
end

