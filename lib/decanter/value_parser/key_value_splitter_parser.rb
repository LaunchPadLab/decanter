module Decanter
  module ValueParser
    class KeyValueSplitterParser < Base
      ITEM_DELIM = ','
      PAIR_DELIM = ':'

      result :raw

      parser do |name, val, options|
        item_delimiter = options.fetch(:item_delimiter, ITEM_DELIM)
        pair_delimiter = options.fetch(:pair_delimiter, PAIR_DELIM)
        val.split(item_delimiter).map { |pair| pair.split pair_delimiter }
      end
    end
  end
end

