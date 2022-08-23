module Decanter
  module Parser
    class BooleanParser < ValueParser

      allow TrueClass, FalseClass

      parser do |val, options|
        raise Decanter::ParseError.new 'Expects a single value' if val.is_a? Array
        next if (val.nil? || val === '')
        [1, '1'].include?(val) || !!/true/i.match(val.to_s) || parse_options(val, options)
      end

      def self.parse_options(val, options)
        truth = options.fetch(:truth, '').to_s.downcase
        raise Decanter::ParseError.new 'Expects a single value' if truth.is_a? Array
        accounted_for_values = ['false', 'true', '1', '0', '']
        return false if accounted_for_values.include?(truth)

        !!/#{truth}/i.match(val.to_s)
      end
    end
  end
end
