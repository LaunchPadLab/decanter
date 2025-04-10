module Decanter
  module Parser
    class StringParser < ValueParser
      parser do |val, options|
        next if (val.nil? || val === '')
        next val if val.is_a? String
        val.to_s
      end
    end
  end
end
