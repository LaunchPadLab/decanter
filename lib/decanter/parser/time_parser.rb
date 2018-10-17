module Decanter
  module Parser
    class TimeParser < ValueParser
      allow Time

      parser do |val, options|
        if (parse_format = options[:parse_format])
          ::Time.strptime(val, parse_format)
        else
          ::Time.parse(val)
        end
      end
    end
  end
end
