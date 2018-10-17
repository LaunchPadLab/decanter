module Decanter
  module Parser
    class BooleanParser < ValueParser
      allow TrueClass, FalseClass

      parser do |val, _options|
        [1, '1'].include?(val) || !!/true/i.match(val.to_s)
      end
    end
  end
end
