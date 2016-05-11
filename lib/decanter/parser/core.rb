module Decanter
  module Parser
    module Core

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        # Check if allowed, parse if not
        def parse(name, values, options={})
          case
          when allowed?(values)
            { name => values }
          else
            _parse(name, values, options)
          end
        end

        # Define parser
        def parser(&block)
          @parser = block
        end

        # Set allowed classes
        def allow(*args)
          @allowed = args
        end

        # Set preparsers
        def pre(*parsers)
          @pre = parsers
        end

        # Get prepareer
        def preparsers
          @pre || []
        end

        # Check for allowed classes
        def allowed?(values)
          @allowed && Array.wrap(values).all? do |value|
            @allowed.any? { |allowed| value.is_a? allowed }
          end
        end
      end
    end
  end
end
