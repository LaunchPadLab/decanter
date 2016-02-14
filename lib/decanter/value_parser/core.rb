module Decanter
  module ValueParser
    module Core

      def self.included(base)
        base.extend(ClassMethods)
        ValueParser.register(base)
      end

      module ClassMethods

        def parse(name, val=nil, options={})

          if val.blank?
            if options[:required]
              raise ArgumentError.new("No value for required argument: #{name}")
            else
              return val
            end
          end

          if @allowed && @allowed.include?(val.class)
            return val
          end

          unless @parser
            raise ArgumentError.new("No parser for argument: #{name} with type: #{val.class}")
          end

          @parser.call(name, val, options)
        end

        def parser(&block)
          @parser = block
        end

        def allow(*args)
          @allowed = args.map { |arg| arg == :boolean ? [TrueClass, FalseClass] : arg.to_s.capitalize.constantize }.flatten
        end
      end
    end
  end
end
