module Decanter
  module Parser
    module Core

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        # Meant to be overriden and called by child parser
        def parse(name, values, options={})

          value_ary = values.is_a?(Array) ? values : [values]

          # want to treat 'false' as an actual value
          if value_ary.all? { |value| value.nil? || value == "" }
            if options[:required]
              raise ArgumentError.new("No value for required argument: #{name}")
            else
              return { name => nil }
            end
          end

          if @allowed && value_ary.all? { |value| @allowed.any? { |allowed| value.is_a? allowed } }
            return { name => values }
          end

          unless @parser
            raise ArgumentError.new("No parser for argument: #{name} with types: #{value_ary.map(&:class).join(', ')}")
          end
        end

        def parser(&block)
          @parser = block
        end

        def allow(*args)
          @allowed = args
        end
      end
    end
  end
end
