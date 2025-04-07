# frozen_string_literal: true

module Decanter
  module Parser
    class PassParser < Base
      parser do |val, _options|
        next if val.nil? || val == ''

        val
      end
    end
  end
end
