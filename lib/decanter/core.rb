module Decanter
  module Core
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def input(name, parsers = nil, **options)
        name = [name].flatten

        if name.length > 1 && parsers.blank?
          raise ArgumentError, "#{self.name} no parser specified for input with multiple values."
        end

        handlers[name] = {
          key:     options.fetch(:key, name.first),
          name:    name,
          options: options,
          parsers:  parsers,
          type:    :input
        }
      end

      # rubocop:disable Naming/PredicateName
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
      # rubocop:enable Naming/PredicateName

      def ignore(*args)
        keys_to_ignore.push(*args)
      end

      def strict(mode)
        raise(ArgumentError, "#{name}: Unknown strict value #{mode}") unless [:with_exception, true, false].include? mode
        @strict_mode = mode
      end

      def decant(args)
        return handle_empty_args if args.blank?
        return empty_required_input_error unless required_input_keys_present?(args)
        args = args.to_unsafe_h.with_indifferent_access if args.class.name == 'ActionController::Parameters'
        {}.merge(unhandled_keys(args))
          .merge(handled_keys(args))
      end

      def handle_empty_args
        any_inputs_required? ? empty_args_error : {}
      end

      def any_inputs_required?
        required_inputs.any?
      end

      def required_inputs
        handlers.map do |h|
          options = h.last[:options]
          h.first.first if options && options[:required]
        end
      end

      def required_input_keys_present?(args = {})
        return true unless any_inputs_required?
        compact_inputs = required_inputs.compact
        compact_inputs.all? do |input|
          args.keys.map(&:to_sym).include?(input) && !args[input].nil?
        end
      end

      def empty_required_input_error
        raise(MissingRequiredInputValue, 'Required inputs have been declared, but no values for those inputs were passed.')
      end

      def empty_args_error
        raise(ArgumentError, 'Decanter has required inputs but no values were passed')
      end

      # protected

      def unhandled_keys(args)
        unhandled_keys = args.keys.map(&:to_sym) -
                         handlers.keys.flatten.uniq -
                         keys_to_ignore -
                         handlers.values
                                 .reject { |handler| handler[:type] == :input }
                                 .map { |handler| "#{handler[:name]}_attributes".to_sym }

        if unhandled_keys.any?
          case strict_mode
          when true
            {}
          when :with_exception
            raise(UnhandledKeysError, "#{name} received unhandled keys: #{unhandled_keys.join(', ')}.")
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
        send("handle_#{handler[:type]}", handler, values)
      end

      def handle_input(handler, args)
        values = args.values_at(*handler[:name])
        values = values.length == 1 ? values.first : values
        parse(handler[:key], handler[:parsers], values, handler[:options])
      end

      def handle_association(handler, args)
        assoc_handlers = [
          handler,
          handler.merge(
            key:   handler[:options].fetch(:key, "#{handler[:name]}_attributes").to_sym,
            name:  "#{handler[:name]}_attributes".to_sym
          )
        ]

        assoc_handler_names = assoc_handlers.map { |h| h[:name] }

        case args.values_at(*assoc_handler_names).compact.length
        when 0
          {}
        when 1
          handler = assoc_handlers.detect { |h| args.key?(h[:name]) }
          send("handle_#{handler[:type]}", handler, args[handler[:name]])
        else
          raise ArgumentError, "Handler #{handler[:name]} matches multiple keys: #{assoc_handler_names}."
        end
      end

      def handle_has_many(handler, values)
        decanter = decanter_for_handler(handler)
        if values.is_a?(Hash)
          parsed_values = values.map do |_index, input_values|
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
          Decanter.decanter_from(specified_decanter)
        else
          Decanter.decanter_for(handler[:assoc])
        end
      end

      def parse(key, parsers, values, options)
        if !parsers
          { key => values }
        elsif options[:required] == true && Array.wrap(values).all? { |value| value.nil? || value == '' }
          raise ArgumentError, "No value for required argument: #{key}"
        else
          Parser.parsers_for(parsers)
                .reduce(key => values) do |vals_hash, parser|
                  vals_hash.keys.reduce({}) { |acc, k| acc.merge(parser.parse(k, vals_hash[k], options)) }
                end
        end
      end

      def handlers
        @handlers ||= {}
      end

      def keys_to_ignore
        @keys_to_ignore ||= []
      end

      def strict_mode
        @strict_mode.nil? ? Decanter.configuration.strict : @strict_mode
      end
    end
  end
end
