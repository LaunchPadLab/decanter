module Decanter
  module ValueParser
    class JoinParser < Base
      DELIM = ','

      parser do |name, val, options|
        delimiter = options.fetch(:delimiter, ITEM_DELIM)
        val.join(DELIM)
      end
    end
  end
end

