module Rails
  module Generators
    class DecanterGenerator < NamedBase
      source_root File.expand_path('templates', __dir__)
      check_class_collision suffix: 'Decanter'
      ASSOCIATION_TYPES = %i[has_many has_one belongs_to].freeze

      argument :attributes, type: :array, default: [], banner: 'field:type field:type'

      class_option :parent, type: :string, desc: 'The parent class for the generated decanter'

      def create_decanter_file
        template 'decanter.rb.erb', File.join('app/decanters', class_path, "#{file_name}_decanter.rb")
      end

      private

      def inputs
        attributes.find_all { |attr| ASSOCIATION_TYPES.exclude?(attr.type) }
      end

      def associations
        attributes - inputs
      end

      def parent_class_name
        'Decanter::Base'
      end
    end
  end
end
