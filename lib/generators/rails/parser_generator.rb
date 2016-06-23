module Rails
  module Generators
    class ParserGenerator < NamedBase
      source_root File.expand_path('../templates', __FILE__)
      check_class_collision :suffix => 'Parser'

      class_option :parent, :type => :string, :desc => 'The parent class for the generated parser'

      def create_parser_file
        template 'parser.rb.erb', File.join('lib/decanter/parsers', class_path, "#{file_name}_parser.rb")
      end

      private

      def parent_class_name
        'Decanter::Parser::ValueParser'
      end
    end
  end
end
