module Decanter
  module CollectionDetection
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def decant(args, **options)
        return super(args) unless collection?(args, options[:is_collection])

        args.map { |resource| super(resource) }
      end

      private

      # leveraging the approach used in the [fast JSON API gem](https://github.com/Netflix/fast_jsonapi#collection-serialization)
      def collection?(args, collection_option = nil)
        return collection_option == true unless collection_option.nil?

        args.respond_to?(:size) && !args.respond_to?(:each_pair)
      end
    end
  end
end
