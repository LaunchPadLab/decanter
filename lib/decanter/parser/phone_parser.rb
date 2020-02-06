module Decanter
  module Parser
    class PhoneParser < ValueParser
      REGEX = /\d/

      allow Integer

      parser do |val, options|
        raise Decanter::ParseError.new 'Expects a single value' if val.is_a? Array
        next if (val.nil? || val === '')
        val.scan(REGEX).join.to_s
      end
    end
  end
end
