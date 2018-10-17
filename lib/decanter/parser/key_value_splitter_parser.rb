module Decanter
  module Parser
    class KeyValueSplitterParser < HashParser
      ITEM_DELIM = ','.freeze
      PAIR_DELIM = ':'.freeze

      parser do |_name, val, options|
        item_delimiter = options.fetch(:item_delimiter, ITEM_DELIM)
        pair_delimiter = options.fetch(:pair_delimiter, PAIR_DELIM)
        val.split(item_delimiter).reduce({}) { |memo, pair| memo.merge(Hash[*pair.split(pair_delimiter)]) }
      end
    end
  end
end
