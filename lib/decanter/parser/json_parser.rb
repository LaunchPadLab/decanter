module Decanter
  module Parser
    class JsonParser < ValueParser

      parser do |val, options|
        next if (val.nil? || val === '')
        raise Decanter::ParseError.new 'Expects a JSON string' unless val.is_a?(String)
        JSON.parse(val)
      end
    end
  end
end
