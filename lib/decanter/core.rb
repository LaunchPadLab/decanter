# frozen_string_literal: true

module Decanter
  module Core
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Declare an ordinary parameter transformation.
      def input(name, parsers = nil, **options)
        options[:type] = :input
        options[:parsers] = parsers
        handler(name, options)
      end

      # rubocop:disable Naming/PredicateName

      # Declare a _has many_ association for a parameter.
      def has_many(name, **options)
        options[:type] = :has_many
        options[:assoc] = name
        handler(name, options)
      end

      # Declare a _has one_ association for a parameter.
      def has_one(name, **options)
        options[:type] = :has_one
        options[:assoc] = name
        handler(name, options)
      end
      # rubocop:enable Naming/PredicateName

      # Add a parameter handler to the class.  Takes a name, and a set of
      # options.  This is a generic method for any sort of hanlder, e.g.
      #
      # handle :foo, type: :input, parsers: [:string], as: :bar
      def handler(name, options)
        name = options.fetch(:as, name)
        parsers = options.delete(:parsers)

        if Array(name).length > 1 && parsers.blank?
          raise ArgumentError,
                "#{name} no parser specified for input with multiple values."
        end

        if handlers.key?(name)
          raise ArgumentError, "Handler for #{name} already defined"
        end

        handlers[name] = {
          key:     options.fetch(:key, Array(name).first),
          assoc:   options.delete(:assoc),
          type:    options.delete(:type),
          options: options,
          parsers: Array(parsers)
        }
      end

      # List of parameters to ignore.
      def ignore(*args)
        keys_to_ignore.push(*args)
      end

      # Set a level of strictness when dealing with parameters that are present
      # but not expected.
      #
      # with_exception:  Raise an execption
      # true:            Delete the parameter
      # false:           Allow the parameter through
      #
      def strict(mode)
        raise(ArgumentError, "#{name}: Unknown strict value #{mode}") unless [:with_exception, true, false].include? mode
        @strict_mode = mode
      end

      # Take a parameter hash, and handle it with the various decanters
      # defined.
      def decant(args)
        return handle_empty_args if args.blank?
        return empty_required_input_error unless required_input_keys_present?(args)

        if args.is_a?(ActionController::Parameters)
          args.permit!
          args = args.to_h
        end

        args = args.deep_symbolize_keys
        handled_keys(args).merge(unhandled_keys(args))
      end

      def required_inputs
        handlers.map do |name, handler|
          name if handler[:options][:required]
        end
      end

      def required_input_keys_present?(args = {})
        return true unless required_inputs.any?
        compact_inputs = required_inputs.compact
        compact_inputs.all? do |input|
          args.keys.map(&:to_sym).include?(input) && !args[input].nil?
        end
      end

      def empty_required_input_error(name = nil)
        raise MissingRequiredInputValue, "No value found for required argument #{name}"
      end

      # protected

      def unhandled_keys(args)
        unhandled = args.keys
        unhandled -= keys_to_ignore
        unhandled -= handlers.keys.flatten

        return {} unless unhandled.any?

        case strict_mode
        when true
          {}
        when :with_exception
          raise(UnhandledKeysError, "#{name} received unhandled keys: #{unhandled.join(', ')}.")
        else
          args.select { |key| unhandled.include? key }
        end
      end

      def handled_keys(args)
        handlers.reduce({}) do |m, h|
          name, handler = *h
          values = args.values_at(*name)
          values = values.length == 1 ? values.first : values

          if handler[:options][:required] && Array(values).all?(&:blank?)
            empty_required_input_error(name)
          end

          m.merge handle(handler, values)
        end
      end

      def handle(handler, values)
        decanter =  decanter_for_handler(handler) unless handler[:type] == :input

        val = case handler[:type]
              when :input
                parse(handler[:parsers], values, handler[:options])
              when :has_one
                decanter.decant(values)
              when :has_many
                # should sort here, really.
                values = values.values if values.is_a?(Hash)
                values.compact.map { |v| decanter.decant(v) }
              end

        { handler[:key] => val }
      end

      def decanter_for_handler(handler)
        if (specified_decanter = handler[:options][:decanter])
          Decanter.decanter_from(specified_decanter)
        else
          Decanter.decanter_for(handler[:assoc])
        end
      end

      def handle_empty_args
        required_inputs.any? ? empty_required_input_error : {}
      end

      def parse(parsers, values, options)
        return values if parsers.nil?

        Parser.parsers_for(parsers).each do |parser|
          unless values.is_a?(Hash)
            values = parser.parse(values, options)
            next
          end

          # For hashes, we operate the parser on each member
          values.each do |k, v|
            values[k] = parser.parse(v, options)
          end
        end

        values
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
