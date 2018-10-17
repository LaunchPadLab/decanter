# frozen_string_literal: true

module Decanter
  module Parser
    class DateTimeParser < ValueParser
      allow DateTime

      parser do |val, options|
        parse_format = options.fetch(:parse_format, '%m/%d/%Y %I:%M:%S %p')
        ::DateTime.strptime(val, parse_format)
      end
    end
  end
end
