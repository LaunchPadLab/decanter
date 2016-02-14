module Decanter
  module ValueParser
    class BooleanParser < Base

      allow :boolean

      parser do |name, val, options|
        [1, '1'].include?(val) || !!/true/i.match(val.to_s)
      end
    end
  end
end
