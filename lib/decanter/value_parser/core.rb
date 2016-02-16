module Decanter
  module ValueParser
    module Core

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def parse(name, values=[], options={})

          if values.none?
            if options[:required]
              raise ArgumentError.new("No value for required argument: #{name}")
            else
              return [name, nil]
            end
          end

          if @allowed && values.all? { |value| @allowed.include?(value.class) }
            return [name, values]
          end

          unless @parser
            raise ArgumentError.new("No parser for argument: #{name} with types: #{values.map(&:class).join(', ')}")
          end

          case @result
          when :raw
            # Parser result must be one of the following:
            #  A 1-D array in the form [key, value, key, value, ...]
            #  A 2-D array in the form [[key, value], [key, value], ...]
            #  A hash
            @parser.call(name, values.length == 1 ? values.first : values, options)
          else
            # Parser result will be treated as a single value
            # belonging to the name
            [name, @parser.call(name, values.length == 1 ? values.first : values, options)]
          end
        end

        def parser(&block)
          @parser = block
        end

        def allow(*args)
          @allowed = args
        end

        def result(opt)
          @result = opt
        end
      end
    end
  end
end
