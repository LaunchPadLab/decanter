module Decanter
  module Extensions

    def self.included(base)
      base.extend(ClassMethods)
    end

    def decant_update(args={}, context=nil)
      self.attributes = self.class.decant(args)
      self.save(context: context)
    end

    def decant_update!(args={}, context=nil)
      self.attributes = self.class.decant(args)
      self.save!(context: context)
    end

    module ClassMethods

      def decant_create(args={}, context=nil)
        self.new(decant(args)).save(context: context)
      end

      def decant_new(args={}, context=nil)
        self.new(decant(args))
      end

      def decant_create!(args={}, context=nil)
        self.new(decant(args)).save!(context: context)
      end

      def decant(args)
        Decanter.decanter_for(self).decant(args)
      end
    end
  end
end
