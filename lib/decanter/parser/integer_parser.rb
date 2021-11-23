module Decanter
  module Parser
    class IntegerParser < ValueParser
      REGEX = /(\d|[.]|[-])/

      allow Integer

      parser do |val, options|
        raise Decanter::ParseError.new 'Expects a single value' if val.is_a? Array
        next if (val.nil? || val === '')
        val.is_a?(Float) ?
          val.to_i :
          val.scan(REGEX).join.try(:to_i)
      end
    end
  end
end
