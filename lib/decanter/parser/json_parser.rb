module Decanter
  module Parser
    class JsonParser < ValueParser

      allow String

      parser do |val, options|
        raise Decanter::ParseError.new 'Expects a single value' if val.is_a? Array
        next if (val.nil? || val === '')
        JSON.parse(val)
      end
    end
  end
end
