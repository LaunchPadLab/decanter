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

      def decant(args, options={})
        # raise ArgumentError if args.blank? && has_required_inputs?()
        # nil and {}.present == false
        # raise ArgumentError.new("#{self.}")
        if options[:decanter].present?
          decanter_from_options(options)
        else
          decanter_for_self
        end.decant(args)
      end
      
      def decanter_with_required_inputs?(decanter_klass)
        decanter_klass
          .collect_handler_options
          .reduce_to_hash
          .required_key_present?
      end
  
      def collect_handler_options
        handlers.collect {|k| k[1][:options]}
      end
  
      def reduce_to_hash
        reduce {|f, s| f.merge(s)}
      end
  
      def required_key_present?
        [:required].present?
      end
  
      def decanter_from_options(options)
        specified_decanter = options[:decanter]
        Decanter.decanter_from(specified_decanter)
      end
  
      def decanter_for_self
        Decanter.decanter_for(self)
      end
    end

    module ActiveRecordExtensions
      def self.enable!
        ::ActiveRecord::Base.include(Decanter::Extensions)
      end
    end
  end
end
