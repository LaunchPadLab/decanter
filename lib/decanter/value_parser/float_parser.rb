module Decanter
  module ValueParser
    class FloatParser < Base
      REGEX = /(\d|[.])/
      parser do |val, options|
        return val if ["Float", "Fixnum"].include?(val.class.name)
        val.scan(REGEX).join.try(:to_f)
      end
    end
  end
end
