module Decanter
  module Parser
    class JsonParser < ValueParser

      parser do |val, options|
        raise Decanter::ParseError.new 'Expects a JSON string' if val.is_a?(Array) || val.is_a?(Hash)
        next if (val.nil? || val === '')
        JSON.parse(val)
      end
    end
  end
end
