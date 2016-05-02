module Decanter
  module Parser
    class RequiredParser < ValueParser

      parser do |val, options|
        no_values = Array.wrap(val).all? { |value| value.nil? || value == "" }
        if no_values
          if options[:required] == true
            raise ArgumentError.new("No value for required argument: #{name}")
          else
            nil
          end
        else
          val
        end
      end
    end
  end
end
