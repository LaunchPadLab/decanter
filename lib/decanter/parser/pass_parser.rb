module Decanter
  module Parser
    class PassParser < ValueParser

      parser do |val, options|
        next if (val.nil? || val == '')
        val
      end
    end
  end
end
