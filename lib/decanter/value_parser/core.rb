module Decanter
  module ValueParser
    module Core

      def self.included(base)
        base.extend(ClassMethods)
        ValueParser.register(base)
      end

      module ClassMethods

        def parse(val, options={})
          if val.blank?
            if options[:required]
              raise ArgumentError.new('No value for required argument')
            else
              return val
            end
          end
        end
      end
    end
  end
end
