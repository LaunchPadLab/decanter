# frozen_string_literal: true

module Decanter
  module Parser
    class BooleanParser < ValueParser
      allow TrueClass, FalseClass

      parser do |val, _options|
        next if val.nil? || val === ''

        true_values = [1, '1', true, 'true', 'TRUE', 'True']
        true_values.include?(val) || val.to_s.downcase == 'true'
      end
    end
  end
end
