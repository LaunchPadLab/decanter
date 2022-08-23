module Decanter
  module Parser
    class BooleanParser < ValueParser

      allow TrueClass, FalseClass

      parser do |val, options|
        single_value_check(val)
        next if (val.nil? || val === '')
        [1, '1'].include?(val) || !!/true/i.match(val.to_s) || parse_options(val, options)
      end

      def self.parse_options(val, options)
        raw_true_value = options.fetch(:true_value, nil)
        return false if raw_true_value.nil?

        single_value_check(raw_true_value)
        true_value = raw_true_value.to_s.downcase

        # want to avoid using values that are already implemented
        accounted_for_values = ['false', 'true', '1', '0', '']
        return false if accounted_for_values.include?(true_value)

        !!/#{true_value}/i.match(val.to_s)
      end

      def self.single_value_check(v)
        raise Decanter::ParseError.new 'Expects a single value' if v.is_a? Array
      end
    end
  end
end
