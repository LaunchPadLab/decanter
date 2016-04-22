module Decanter
  module Core

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def input(name, parser=nil, **options)

        _name = [name].flatten

        if _name.length > 1 && parser.blank?
          raise ArgumentError.new("#{self.name} no parser specified for input with multiple values.")
        end

        handlers[_name] = {
          key:     options.fetch(:key, _name.first),
          name:    _name,
          options: options,
          parser:  parser,
          type:    :input
        }
      end

      def has_many(assoc, **options)
        handlers[assoc] = {
          assoc:   assoc,
          key:     options.fetch(:key, assoc),
          name:    assoc,
          options: options,
          type:    :has_many
        }
      end

      def has_one(assoc, **options)
        handlers[assoc] = {
          assoc:   assoc,
          key:     options.fetch(:key, assoc),
          name:    assoc,
          options: options,
          type:    :has_one
        }
      end

      def strict(mode)
        raise( ArgumentError.new("#{self.name}: Unknown strict value #{mode}")) unless [:with_exception, true, false].include? mode
        @strict_mode = mode
      end

      def decant(args)
        args = args.to_unsafe_h.with_indifferent_access if args.class.name == 'ActionController::Parameters'
        {}.merge( unhandled_keys(args) )
          .merge( handled_keys(args) )
      end

      # protected

      def unhandled_keys(args)
        unhandled_keys = args.keys.map(&:to_sym) -
          handlers.keys.flatten.uniq -
          handlers.values
            .select { |handler| handler[:type] != :input }
            .map { |handler| "#{handler[:name]}_attributes".to_sym }

        if unhandled_keys.any?
          case strict_mode
          when true
            p "#{self.name} ignoring unhandled keys: #{unhandled_keys.join(', ')}."
            {}
          when :with_exception
            raise ArgumentError.new("#{self.name} received unhandled keys: #{unhandled_keys.join(', ')}.")
          else
            args.select { |key| unhandled_keys.include? key }
          end
        else
          {}
        end
      end

      def handled_keys(args)
        arg_keys = args.keys.map(&:to_sym)
        inputs, assocs = handlers.values.partition { |handler| handler[:type] == :input }

        {}.merge(
          # Inputs
          inputs.select     { |handler| (arg_keys & handler[:name]).any? }
                .reduce({}) { |memo, handler| memo.merge handle_input(handler, args) }
        ).merge(
          # Associations
          assocs.reduce({}) { |memo, handler| memo.merge handle_association(handler, args) }
        )
      end

      def handle(handler, args)
        values = args.values_at(*handler[:name])
        values = values.length == 1 ? values.first : values
        self.send("handle_#{handler[:type]}", handler, values)
      end

      def handle_input(handler, args)
         values = args.values_at(*handler[:name])
         values = values.length == 1 ? values.first : values
         parse(handler[:key], handler[:parser], values, handler[:options])
      end

      def handle_association(handler, args)
        assoc_handlers = [
          handler,
          handler.merge({
            key:   handler[:options].fetch(:key, "#{handler[:name]}_attributes").to_sym,
            name:  "#{handler[:name]}_attributes".to_sym
          })
        ]

        assoc_handler_names = assoc_handlers.map { |_handler| _handler[:name] }

        case args.values_at(*assoc_handler_names).compact.length
        when 0
          {}
        when 1
          _handler = assoc_handlers.detect { |_handler| args.has_key?(_handler[:name]) }
          self.send("handle_#{_handler[:type]}", _handler, args[_handler[:name]])
        else
          raise ArgumentError.new("Handler #{handler[:name]} matches multiple keys: #{assoc_handler_names}.")
        end
      end

      def handle_has_many(handler, values)
        decanter = decanter_for_handler(handler)
        if values.is_a?(Hash)
          parsed_values = values.map do |index, input_values|
            next if input_values.nil?
            decanter.decant(input_values)
          end
          return { handler[:key] => parsed_values }
        else
          {
            handler[:key] => values.compact.map { |value| decanter.decant(value) }
          }
        end
      end

      def handle_has_one(handler, values)
        { handler[:key] => decanter_for_handler(handler).decant(values) }
      end

      def decanter_for_handler(handler)
        if specified_decanter = handler[:options][:decanter]
          Decanter::decanter_from(specified_decanter)
        else
          Decanter::decanter_for(handler[:assoc])
        end
      end

      def parse(key, parser, values, options)
        parser ?
          ValueParser.parser_for(parser)
                     .parse(key, values, options)
          :
          { key => values }
      end

      def handlers
        @handlers ||= {}
      end

      def strict_mode
        @strict_mode ||= Decanter::Configuration.strict
      end
    end
  end
end
