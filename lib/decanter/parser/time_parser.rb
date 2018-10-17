# frozen_string_literal: true

module Decanter
  module Parser
    class TimeParser < ValueParser
      allow Time

      parser do |val, options|
        if val.is_a?(DateTime)
          val.to_time
        elsif (parse_format = options[:parse_format])
          ::Time.strptime(val, parse_format)
        else
          ::Time.parse(val)
        end
      end
    end
  end
end
