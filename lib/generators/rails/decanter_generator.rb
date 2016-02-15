module Rails
  module Generators
    class DecanterGenerator < NamedBase
      source_root File.expand_path('../templates', __FILE__)
      check_class_collision :suffix => 'Decanter'

      argument :attributes, :type => :array, :default => [], :banner => 'field:type field:type'

      class_option :parent, :type => :string, :desc => 'The parent class for the generated decanter'

      def create_serializer_file
        template 'serializer.rb.erb', File.join('app/decanters', class_path, "#{file_name}_decanter.rb")
      end

      private

      def attributes_names
        [:id] + attributes.reject(&:reference?).map! { |a| a.name.to_sym }
      end

      def association_names
        attributes.select(&:reference?).map! { |a| a.name.to_sym }
      end

      def parent_class_name
        'Decanter::Base'
      end
    end
  end
end
