module Decanter
  module ValueParser
    class StringParser < Base
      parser do |val, options|
        val.to_s
      end
    end
  end
end
