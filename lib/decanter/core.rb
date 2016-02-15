module Decanter
  module Core

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def associations
        @associations ||= {}.with_indifferent_access
      end

      def inputs
        @inputs ||= {}.with_indifferent_access
      end

      def input(name=nil, type, **options)
        set_input options, {
          name:    name,
          options: options.reject { |k| k == :context },
          type:    type
        }
      end

      def set_input(options, input_cfg)
        set_for_context options, input_cfg, inputs
      end

      def input_for(name, context)
        (inputs[context || :default] || {})[name]
      end

      def has_many(name=nil, **options)
        set_association options, {
          key:     options[:key] || "#{name}_attributes".to_sym,
          name:    name,
          options: options.reject { |k| k == :context },
          type:    :has_many
        }
      end

      def has_one(name=nil, **options)
        set_association options, {
          key:     options[:key] || "#{name}_attributes".to_sym,
          name:    name,
          options: options.reject { |k| k == :context },
          type:    :has_one
        }
      end

      def has_many_for(key, context)
        (associations[context || :default] || {})
          .detect { |name, assoc| assoc[:type] == :has_many && assoc[:key] == key.to_sym}
      end

      def has_one_for(key, context)
        (associations[context || :default] || {})
          .detect { |name, assoc| assoc[:type] == :has_one && assoc[:key] == key.to_sym}
      end

      def set_association(options, assoc)
        set_for_context options, assoc, associations
      end

      def set_for_context(options, arg, hash)
        context = options[:context] || @context || :default
        hash[context] = {} unless hash.has_key? context
        hash[context][arg[:name]] = arg
      end

      def with_context(context, &block)
        raise NameError.new('no context argument provided to with_context') unless context

        @context = context
        block.arity.zero? ? instance_eval(&block) : block.call(self)
        @context = nil
      end

      def decant(args={}, context=nil)
        Hash[
          *args.keys.map { |key| handle_arg(key, args[key], context) }.flatten.compact
        ]
      end

      def handle_arg(name, value, context)
        case
        when input_cfg = input_for(name, context)
          parse(name, input_cfg[:type], value, input_cfg[:options]).flatten
        when assoc = has_one_for(name, context)
          [assoc.pop[:key], Decanter::decanter_for(assoc[1][:options][:decanter] || assoc.first).decant(value, context)]
        when assoc = has_many_for(name, context)
          decanter = Decanter::decanter_for(assoc[1][:options][:decanter] || assoc.first)
          [assoc.pop[:key], value.map { |val| decanter.decant(val, context) }]
        else
          context ? nil : [name, value]
        end
      end

      def parse(name, type, val, options)
        type ?
          ValueParser.value_parser_for(type).parse(name, val, options) :
          [name, val]
      end
    end
  end
end
