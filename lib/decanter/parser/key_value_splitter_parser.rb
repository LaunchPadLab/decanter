module Decanter
  module Parser
    class KeyValueSplitterParser < HashParser
      ITEM_DELIM = ','
      PAIR_DELIM = ':'

      parser do |name, val, options|
        item_delimiter = options.fetch(:item_delimiter, ITEM_DELIM)
        pair_delimiter = options.fetch(:pair_delimiter, PAIR_DELIM)
        val.split(item_delimiter).reduce({}) { |memo, pair| memo.merge( Hash[ *pair.split(pair_delimiter) ] ) }
      end
    end
  end
end

