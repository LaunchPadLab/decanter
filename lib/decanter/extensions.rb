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

      def decant(args, options = {})
        if (specified_decanter = options[:decanter])
          Decanter.decanter_from(specified_decanter)
        else
          Decanter.decanter_for(self)
        end.decant(args)
      end
    end

    module ActiveRecordExtensions
      def self.enable!
        ::ActiveRecord::Base.include(Decanter::Extensions)
      end
    end
  end
end
