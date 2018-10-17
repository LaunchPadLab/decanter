# frozen_string_literal: true

module Decanter
  module Parser
    # rubocop:disable Style/DateTime
    class DateTimeParser < ValueParser
      allow DateTime

      parser do |val, options|
        if (parse_format = options[:parse_format])
          ::DateTime.strptime(val, parse_format)
        else
          ::DateTime.parse(val)
        end
      end
    end
    # rubocop:enable Style/DateTime
  end
end
