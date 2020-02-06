module Decanter
  module Parser
    class BooleanParser < ValueParser

      allow TrueClass, FalseClass

      parser do |val, options|
        raise Decanter::ParseError.new 'Expects a single value' if val.is_a? Array
        next if (val.nil? || val === '')
        [1, '1'].include?(val) || !!/true/i.match(val.to_s)
      end
    end
  end
end
