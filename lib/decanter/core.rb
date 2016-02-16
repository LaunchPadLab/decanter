module Decanter
  module Core

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def input(name=nil, parser=nil, **options)

        if name.is_a?(Array) && name.length > 1 && parser.blank?
          raise ArgumentError.new("#{self.name} no parser specified for input with multiple values.")
        end

        handlers[name] = {
          key:     options.fetch(:key, [name].flatten.first),
          name:    name,
          options: options,
          parser:  parser,
          type:    :input
        }
      end

      def has_many(name=nil, **options)
        handlers[name] = {
          key:     options.fetch(:key, "#{name}_attributes".to_sym),
          name:    name,
          options: options,
          type:    :has_many
        }
      end

      def has_one(name=nil, **options)
        handlers[name] = {
          key:     options.fetch(:key, "#{name}_attributes".to_sym),
          name:    name,
          options: options,
          type:    :has_one
        }
      end

      def strict(mode=nil)
        raise( ArgumentError.new("#{self.name}: Unknown strict value #{mode}")) unless [:with_exception, true, false].include? mode
        @strict_mode = mode
      end

      def decant(args={})

        # will this cause problems? Or i could try ot fetch everything as strings...
        args = args.with_indifferent_access

        {}.merge( unhandled_keys(args) )
          .merge( handled_keys(args) )
      end

      # protected

        def unhandled_keys(args)

          unhandled_keys = args.keys - handlers.keys.flatten.uniq

          if unhandled_keys.any?
            case strict_mode
            when true
              p "#{self.name} ignoring unhandled keys: #{unhandled_keys.join(', ')}."
            when :with_exception
              raise ArgumentError.new("#{self.name} received unhandled keys: #{unhandled_keys.join(', ')}.")
            end
          end
          args.select { |key| unhandled_keys.include? key }
        end

        def handled_keys(args)
          Hash[ handlers.values.map { |handler| handle(handler, args) } ]
        end

        def handle(handler, args)
          values = args.values_at(*handler[:name])
          self.send("handle_#{handler[:type]}", handler, values)
        end

        def handle_input(handler, values)
           parse(handler[:key], handler[:parser], values, handler[:options]).flatten(1)
        end

        def handle_has_many(handler, values)
            decanter = decanter_for_handler(handler)
            [
              handler[:key],
              values.map { |value| decanter.decant(value) }
            ]
        end

        def handle_has_one(handler, values)
            [
              handler[:key],
              decanter_for_handler(handler).decant(values)
            ]
        end

        def decanter_for_handler(handler)
          Decanter::decanter_for(handler[:options][:decanter] || handler[:name])
        end

        def parse(key, parser, values, options)
          parser ?
            ValueParser.value_parser_for(parser)
                       .parse(key, values, options)
            :
            [key, values]
        end

        def handlers
          @handlers ||= {}
        end

        def strict_mode
          @strict_mode ||= {}
        end
    end
  end
end
