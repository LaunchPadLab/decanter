module Decanter
  module Parser
    class DateParser < ValueParser
      allow Date

      parser do |val, options|
        parse_format = options.fetch(:parse_format, '%m/%d/%Y')
        ::Date.strptime(val, parse_format)
      end
    end
  end
end
