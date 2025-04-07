# frozen_string_literal: true

module Decanter
  module Parser
    class PhoneParser < ValueParser
      REGEX = /\d/

      allow Integer

      parser do |val, _options|
        next if val.nil? || val == ''

        val.scan(REGEX).join.to_s
      end
    end
  end
end
