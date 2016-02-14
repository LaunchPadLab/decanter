module Decanter
  module ValueParser
    module Core
      def self.included(base)
        base.extend(ClassMethods)
        ValueParser.register(base)
      end

      module ClassMethods
        def parse(val, options={})
          val
        end
      end
    end
  end
end
