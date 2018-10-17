module Decanter
  module Parser
    class JoinParser < ValueParser
      DELIM = ','.freeze

      parser do |val, options|
        delimiter = options.fetch(:delimiter, ITEM_DELIM)
        val.join(DELIM)
      end
    end
  end
end
