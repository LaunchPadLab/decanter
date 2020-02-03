module Decanter
  module Parser
    class StringParser < ValueParser
      parser do |val, options|
        raise Decanter::ParseError if val.is_a? Array
        next if (val.nil? || val === '')
        next val if val.is_a? String
        val.to_s
      end
    end
  end
end
