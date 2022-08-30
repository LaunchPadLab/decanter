module Decanter
  module Parser
    class BooleanParser < ValueParser

      allow TrueClass, FalseClass

      parser do |val, options|
        normalized_val = normalize(val)
        next if normalized_val.nil?

        true_values = ['1', 'true']

        option_val = options.fetch(:true_value, nil)
        normalized_option = normalize(option_val)

        true_values << normalized_option if normalized_option
        true_values.find {|tv| !!/#{tv}/i.match(normalized_val)}.present?
      end

      def self.normalize(value)
        return if (value.nil? || value === '')
        raise Decanter::ParseError.new 'Expects a single value' if value.is_a? Array
        value.to_s.downcase
      end
    end
  end
end
