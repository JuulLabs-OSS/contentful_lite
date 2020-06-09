module ContentfulLite
  module Validations
    class IncludedEntryValidator < ActiveModel::EachValidator
      include IncludedChildValidator
      add_options_keys :allowed_models

      def validate_child(record, attr_name, value, idx = nil)
        unless value.is_a?(ContentfulLite::Entry)
          record_error(record, attr_name, "value#{idx} is not a published entry")
          return
        end
        record_error(record, attr_name, "value has invalid child entry #{value.id}") unless value.valid?(locale: record.locale)
        record_error(record, attr_name, "value#{idx} has an invalid entry model. Expecting #{options[:allowed_models]}") if invalid_model?(value)
      end

      def invalid_model?(value)
        return false unless options[:allowed_models]

        options[:allowed_models]&.none?{ |type| value.is_a?(type) }
      end
    end
  end
end
