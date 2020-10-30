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
        is_collection?(args, options[:is_collection]) ? decant_collection(args, options) : decant_args(args, options)
      end

      def decant_collection(args, options)
        args.map { |resource| decant_args(resource, options) }
      end

      def decant_args(args, options)
        if specified_decanter = options[:decanter]
          Decanter.decanter_from(specified_decanter)
        else
          Decanter.decanter_for(self)
        end.decant(args)
      end

      ## leveraging the approach used in the [fast JSON API gem](https://github.com/Netflix/fast_jsonapi#collection-serialization)
      def is_collection?(args, collection_option=nil)
        return collection_option[:is_collection] unless collection_option.nil?
        args.respond_to?(:size) && !args.respond_to?(:each_pair)
      end
    end

    module ActiveRecordExtensions
      def self.enable!
        ::ActiveRecord::Base.include(Decanter::Extensions)
      end
    end
  end
end
