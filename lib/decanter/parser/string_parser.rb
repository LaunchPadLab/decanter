module Decanter
  module Parser
    class StringParser < ValueParser

      allow String

      parser do |val, options|
        val.to_s
      end
    end
  end
end
