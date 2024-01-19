module Decanter
  module Parser
    class PassParser < Base

      parser do |val, options|
        next if (val.nil? || val == '')
        val
      end
    end
  end
end
