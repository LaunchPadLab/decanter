module Decanter
  module Parser
    class DateParser < ValueParser

      allow Date

      parser do |val, options|
        raise Decanter::ParseError.new 'Expects a single value' if val.is_a? Array
        next if (val.nil? || val === '')
        parse_format = options.fetch(:parse_format, '%m/%d/%Y')
        begin
        ::Date.strptime(val, parse_format)
        rescue ArgumentError => e
          raise Decanter::ValueFormatError.new 'invalid Date value for format' if e.message == "invalid date"
        end
      end
    end
  end
end

