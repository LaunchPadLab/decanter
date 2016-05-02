module Decanter
  module Parser
    module Core

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def parse(name, values, options={})
          case
          when allowed?(values)
            { name => values }
          else
            _parse(name, values, options)
          end
        end

        def parser(&block)
          @parser = block
        end

        def allow(*args)
          @allowed = args
        end

        def allowed?(values)
          @allowed && Array.wrap(values).all? do |value|
            @allowed.any? { |allowed| value.is_a? allowed }
          end
        end
      end
    end
  end
end
