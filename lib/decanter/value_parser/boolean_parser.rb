module Decanter
  module ValueParser
    class BooleanParser < Base
      def self.parse(val=nil, options={})
        super(val, options)
        [1, '1', true].include?(val) || !!/true/i.match(val.to_s)
      end
    end
  end
end
