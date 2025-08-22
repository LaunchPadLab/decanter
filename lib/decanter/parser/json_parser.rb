module Decanter
  module Parser
    class JsonParser < ValueParser

      parser do |val, options|
        next if val.blank?
        raise Decanter::ParseError.new 'Expects a JSON string' unless val.is_a?(String)
        parse_json(val)
      end

      def self.parse_json(val)
        begin
          JSON.parse(val)
        rescue 
          raise Decanter::ParseError.new 'Invalid JSON string'
        end
      end
    end
  end
end
