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
        if specified_decanter = options[:decanter]
          get_decanter_from(specified_decanter)
        else
          get_decanter_for(self)
        end.decant(args)
      end
    end
    #drill down in handlers:
    # array_of_hashes = SummitDecanter.handlers.collect{|n| n[1][:options]}
    # reduce to single hash:
    # hash = array_of_hashes.reduce{|f, s| f.merge(s)}
    # check for :required key
    # hash[:required].present?
    def return_decanter_from(specified_decanter)
      Decanter.decanter_from(specified_decanter)
    end
    def return_decanter_for(self)
      Decanter.decanter_for(self)
    end

    def required_handlers?(klass)
      Decanter.decanter_for
    end

    module ActiveRecordExtensions
      def self.enable!
        ::ActiveRecord::Base.include(Decanter::Extensions)
      end
    end
  end
end
