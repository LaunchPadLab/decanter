module Decanter
  module Parser
    class BooleanParser < Base

      allow TrueClass, FalseClass

      parser do |name, val, options|
        [1, '1'].include?(val) || !!/true/i.match(val.to_s)
      end
    end
  end
end
