# frozen_string_literal: true

module Decanter
  module Parser
    class JoinParser < ValueParser
      DELIM = ','

      parser do |val, options|
        delimiter = options.fetch(:delimiter, ITEM_DELIM)
        val.join(DELIM)
      end
    end
  end
end
