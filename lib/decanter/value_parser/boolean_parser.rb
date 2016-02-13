module Decanter
  module ValueParser
    class BooleanParser < Base
      def self.parse(val)
        case val
        when nil
          nil
        when 1, '1', true, 'true'
          true
        else
          false
        end
      end
    end
  end
end
