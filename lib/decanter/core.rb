# frozen_string_literal: true

require 'action_controller'

module Decanter
  module Core
    DEFAULT_VALUE_KEY = :default_value
    ACTION_CONTROLLER_PARAMETERS_CLASS_NAME = 'ActionController::Parameters'

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def input(name, parsers = nil, **options)
        # Convert all input names to symbols to correctly calculate handled vs. unhandled keys
        input_names = [name].flatten.map(&:to_sym)

        if input_names.length > 1 && parsers.blank?
          raise ArgumentError, "#{self.name} no parser specified for input with multiple values."
        end

        handlers[input_names] = {
          key: options.fetch(:key, input_names.first),
          name: input_names,
          options:,
          parsers:,
          type: :input
        }
      end

      # Adjusting has_many to explicitly define keyword arguments
      def has_many(assoc, **options)
        handlers[assoc] = {
          assoc:,
          key: options.fetch(:key, assoc),
          name: assoc,
          options:,
          type: :has_many
        }
      end

      # Adjusting has_one similarly
      def has_one(assoc, **options)
        handlers[assoc] = {
          assoc:,
          key: options.fetch(:key, assoc),
          name: assoc,
          options:,
          type: :has_one
        }
      end

      def ignore(*)
        keys_to_ignore.push(*).map!(&:to_sym)
      end

      def strict(mode)
        raise(ArgumentError, "#{name}: Unknown strict value #{mode}") unless [:ignore, true,
                                                                              false].include? mode

        @strict_mode = mode
      end

      def log_unhandled_keys(mode)
        raise(ArgumentError, "#{name}: Unknown log_unhandled_keys value #{mode}") unless [true,
                                                                                          false].include? mode

        @log_unhandled_keys_mode = mode
      end

      def decant(args)
        return handle_empty_args if args.blank?
        return empty_required_input_error unless required_input_keys_present?(args)

        # Convert all params passed to a decanter to a hash with indifferent access to mitigate accessor ambiguity
        accessible_args = to_indifferent_hash(args)
        {}.merge(default_keys)
          .merge(unhandled_keys(accessible_args))
          .merge(handled_keys(accessible_args))
      end

      def default_keys
        # return keys with provided default value when key is not defined within incoming args
        default_result = default_value_inputs
                         .to_h { |input| [input[:key], input[:options][DEFAULT_VALUE_KEY]] }

        # parse handled default values, including keys
        # with defaults not already managed by handled_keys
        default_result.merge(handled_keys(default_result))
      end

      def default_value_inputs
        handlers.values.select { |input| input[:options].key?(DEFAULT_VALUE_KEY) }
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
        raise(MissingRequiredInputValue,
              'Required inputs have been declared, but no values for those inputs were passed.')
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
                                 .map { |handler| :"#{handler[:name]}_attributes" }

        return {} unless unhandled_keys.any?

        case strict_mode
        when :ignore
          p "#{name} ignoring unhandled keys: #{unhandled_keys.join(', ')}." if log_unhandled_keys_mode
          {}
        when true
          raise(UnhandledKeysError,
                "#{name} received unhandled keys: #{unhandled_keys.join(', ')}.")
        else
          args.select { |key| unhandled_keys.include? key.to_sym }
        end
      end

      def handled_keys(args)
        arg_keys = args.keys.map(&:to_sym)
        inputs, assocs = handlers.values.partition { |handler| handler[:type] == :input }
        {}.merge(
          # Inputs
          inputs.select     { |handler| arg_keys.intersect?(handler[:name]) }
                .reduce({}) { |memo, handler| memo.merge handle_input(handler, args) }
        ).merge(
          # Associations
          assocs.reduce({}) { |memo, handler| memo.merge handle_association(handler, args) }
        )
      end

      def handle(handler, args)
        values = args.values_at(*handler[:name])
        values = values.first if values.length == 1
        send("handle_#{handler[:type]}", handler, values)
      end

      def handle_input(handler, args)
        values = args.values_at(*handler[:name])
        values = values.first if values.length == 1
        parse(handler[:key], handler[:parsers], values, handler[:options])
      end

      def handle_association(handler, args)
        assoc_handlers = [
          handler,
          handler.merge({
                          key: handler[:options].fetch(:key, "#{handler[:name]}_attributes").to_sym,
                          name: :"#{handler[:name]}_attributes"
                        })
        ]

        assoc_handler_names = assoc_handlers.map { |_handler| _handler[:name] }

        case args.values_at(*assoc_handler_names).compact.length
        when 0
          {}
        when 1
          _handler = assoc_handlers.detect { |_handler| args.key?(_handler[:name]) }
          send("handle_#{_handler[:type]}", _handler, args[_handler[:name]])
        else
          raise ArgumentError,
                "Handler #{handler[:name]} matches multiple keys: #{assoc_handler_names}."
        end
      end

      def handle_has_many(handler, values)
        decanter = decanter_for_handler(handler)
        if values.is_a?(Hash)
          parsed_values = values.map do |_index, input_values|
            next if input_values.nil?

            decanter.decant(input_values)
          end
          { handler[:key] => parsed_values }
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
        if (specified_decanter = handler[:options][:decanter])
          Decanter.decanter_from(specified_decanter)
        else
          Decanter.decanter_for(handler[:assoc])
        end
      end

      def parse(key, parsers, value, options)
        return { key => value } unless parsers

        if options[:required] && value_missing?(value)
          raise ArgumentError,
                "No value for required argument: #{key}"
        end

        parser_classes = Parser.parsers_for(parsers)
        Parser.compose_parsers(parser_classes).parse(key, value, options)
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

      def log_unhandled_keys_mode
        return !!Decanter.configuration.log_unhandled_keys if @log_unhandled_keys_mode.nil?

        !!@log_unhandled_keys_mode
      end

      # Helpers

      private

      def value_missing?(value)
        value.nil? || value == ''
      end

      def to_indifferent_hash(args)
        return args.to_unsafe_h if args.instance_of?(ActionController::Parameters)

        args.to_h.with_indifferent_access
      end
    end
  end
end
