# frozen_string_literal: true

module Decanter
  module Parser
    module Utils
      # extract string transformation strategies
      def symbol_to_string(klass_or_sym)
        if singular_class_present?(klass_or_sym)
          singularize_and_camelize_str(klass_or_sym)
        else
          camelize_str(klass_or_sym)
        end
      end

      def singular_class_present?(klass_or_sym)
        parser_str = singularize_and_camelize_str(klass_or_sym)
        concat_str(parser_str).safe_constantize.present?
      end

      def singularize_and_camelize_str(klass_or_sym)
        klass_or_sym.to_s.singularize.camelize
      end

      def camelize_str(klass_or_sym)
        klass_or_sym.to_s.camelize
      end

      def concat_str(parser_str)
        'Decanter::Parser::' + parser_str
      end
    end
  end
end
