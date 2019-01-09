# frozen_string_literal: true

module Decanter
  module Parser
    class DateParser < ValueParser
      allow Date

      parser do |val, options|
        if (parse_format = options[:parse_format])
          ::Date.strptime(val, parse_format)
        else
          ::Date.parse(val)
        end
      end
    end
  end
end
