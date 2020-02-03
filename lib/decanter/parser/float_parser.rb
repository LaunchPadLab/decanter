module Decanter
  module Parser
    class FloatParser < ValueParser
      REGEX = /(\d|[.])/

      allow Float, Integer

      parser do |val, options|
        raise Decanter::ParseError if val.is_a? Array
        next if (val.nil? || val === '')
        val.scan(REGEX).join.try(:to_f)
      end
    end
  end
end
