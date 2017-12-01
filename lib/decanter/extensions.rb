require 'pry'

module Decanter
  module Extensions

    def self.included(base)
      base.extend(ClassMethods)
    end

    def decant_update(args, **options)
      self.attributes = self.class.decant(args, options)
      self.save(context: options[:context])
    end

    def decant_update!(args, **options)
      self.attributes = self.class.decant(args, options)
      self.save!(context: options[:context])
    end

    def decant(args, **options)
      self.class.decant(args, options)
    end

    module ClassMethods

      def decant_create(args, **options)
        self.new(decant(args, options))
            .save(context: options[:context])
      end

      def decant_new(args, **options)
        self.new(decant(args, options))
      end

      def decant_create!(args, **options)
        self.new(decant(args, options))
            .save!(context: options[:context])
      end
        
      # def decant(args, options={})
      #   if specified_decanter = options[:decanter]
      #     decanter = Decanter.decanter_from(specified_decanter)
      #     raise_inputs_required if has_required_inputs?(decanter)
      #     decanter
      #   else
      #     decanter = Decanter.decanter_for(self)
      #     raise_inputs_required if has_required_inputs?(decanter)
      #     decanter          
      #   end.decant(args)
      # end

      def decant(args, options={})
        if options[:decanter].present?
          decanter = decanter_from_options(options)
          raise_inputs_required if has_required_inputs?(decanter)
          decanter
        else
          decanter = decanter_for_self(self)
          raise_inputs_required if has_required_inputs?(decanter)
          decanter
        end.decant(args)
      end

      private 
      # returns true or false
      def has_required_inputs?(decanter_klass)
        return false if decanter_klass.handlers.blank?
        decanter_klass
          .collect_handler_options
          .reduce_to_hash
          .required_key_present?
      end
      # to be used by has_required_inputs?
      def collect_handler_options
        handlers.collect { |k| k[1][:options] }
      end

      def reduce_to_hash
        reduce { |f, s| f.merge(s) }
      end

      def required_key_present?
        [:required].present?
      end

      def raise_inputs_required
        raise ArgumentError.new("#{decanter} has required input values")
      end
      # decanter setters
      def decanter_from_options(options)
        specified_decanter = options[:decanter]
        Decanter.decanter_from(specified_decanter)
      end

      def decanter_for_self(klass)
        Decanter.decanter_for(klass)
      end
    end

    module ActiveRecordExtensions
      def self.enable!
        ::ActiveRecord::Base.include(Decanter::Extensions)
      end
    end
  end
end
