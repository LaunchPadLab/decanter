module Decanter
  module Parser
    class JoinParser < ValueParser
      ITEM_DELIM = ','

      parser do |val, options|
        delimiter = options.fetch(:delimiter, ITEM_DELIM)
        val.join(delimiter)
      end
    end
  end
end

