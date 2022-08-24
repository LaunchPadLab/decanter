module Decanter
  module Parser
    class DateTimeParser < ValueParser

      allow DateTime

      parser do |val, options|
        raise Decanter::ParseError.new 'Expects a single value' if val.is_a? Array
        next if (val.nil? || val === '')
        parse_format = options.fetch(:parse_format, '%m/%d/%Y %I:%M:%S %p')
        begin
        ::DateTime.strptime(val, parse_format)
        rescue ArgumentError => e
         raise Decanter::ValueFormatError.new 'invalid DateTime value for format' if e.message == "invalid date"
        end
      end
    end
  end
end
