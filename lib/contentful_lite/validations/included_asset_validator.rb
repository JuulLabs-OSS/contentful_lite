module ContentfulLite
  module Validations
    class IncludedAssetValidator < ActiveModel::EachValidator
      include IncludedChildValidator
      add_options_keys :type

      def validate_child(record, attr_name, value, idx = nil)
        record_error(record, attr_name, "value#{idx} is not a published asset") && return unless value.is_a?(ContentfulLite::Asset)
        record_error(record, attr_name, "value#{idx} has an invalid asset type. Expecting #{options[:type]}") if options[:type] && !value&.content_type&.include?(options[:type].to_s)
      end
    end
  end
end
