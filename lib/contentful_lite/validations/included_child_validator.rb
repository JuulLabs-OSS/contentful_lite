module ContentfulLite
  module Validations
    # @api private
    module IncludedChildValidator
      extend ActiveSupport::Concern
      BASE_OPTIONS = %i[allow_blank array].freeze

      def validate_each(record, attr_name, value)
        if value.blank?
          record_error(record, attr_name, "value is blank") unless options[:allow_blank]
        elsif options[:array]
          validate_array(record, attr_name, value)
        else
          validate_child(record, attr_name, value)
        end
      end

      private

      def record_error(record, attr_name, message)
        record.errors.add(attr_name, :invalid, **{ message: message }.merge(options.except(self.class.options_keys)))
      end

      def validate_array(record, attr_name, value)
        record_error(record, attr_name, "value is not an array") && return unless value.is_a?(Array)
        value.each_with_index { |asset, idx| validate_child(record, attr_name, asset, "[#{idx}]") }
      end

      class_methods do
        def add_options_keys(*options)
          @options_keys = BASE_OPTIONS + options
        end

        def options_keys
          @options_keys
        end
      end
    end
  end
end
