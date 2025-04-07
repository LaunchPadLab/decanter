# frozen_string_literal: true

module Decanter
  module Parser
    class IntegerParser < ValueParser
      REGEX = /(\d|[.]|[-])/

      allow Integer

      parser do |val, _options|
        next if val.nil? || val === ''

        if val.is_a?(Float)
          val.to_i
        else
          val.scan(REGEX).join.try(:to_i)
        end
      end
    end
  end
end
