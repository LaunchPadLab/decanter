module Rails
  module Generators
    class DecanterGenerator < NamedBase
      source_root File.expand_path('../templates', __FILE__)
      check_class_collision :suffix => 'Decanter'
      ASSOCIATION_TYPES = [:has_many, :has_one, :belongs_to]

      argument :attributes, :type => :array, :default => [], :banner => 'field:type field:type'

      class_option :parent, :type => :string, :desc => 'The parent class for the generated decanter'

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

      # def attributes_names
      #   [:id] + attributes.reject(&:reference?).map! { |a| a.name.to_sym }
      # end

      # def association_names
      #   attributes.select(&:reference?).map! { |a| a.name.to_sym }
      # end

      def parent_class_name
        'Decanter::Base'
      end
    end
  end
end
