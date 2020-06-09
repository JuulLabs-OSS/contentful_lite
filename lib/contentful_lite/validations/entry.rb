require 'active_support/concern'
require 'active_model'
require 'contentful_lite/validations/included_child_validator'
require 'contentful_lite/validations/included_asset_validator'
require 'contentful_lite/validations/included_entry_validator'

module ContentfulLite
  module Validations
    module Entry
      extend ActiveSupport::Concern

      included do |base_class|
        base_class.include(ActiveModel::Validations)
        base_class.define_method(:errors) do |locale: nil|
          @errors ||= Hash.new { |hash, key| hash[key] = ActiveModel::Errors.new(self) }
          @errors[locale || self.locale]
        end
        base_class.define_method(:valid?) do |locale: nil|
          with_locale(locale) { super() }
        end
      end

      class_methods do
        def validates_included_entry(*attr_names)
          validates_with IncludedEntryValidator, _merge_attributes(attr_names)
        end

        def validates_included_asset(*attr_names)
          validates_with IncludedAssetValidator, _merge_attributes(attr_names)
        end
      end

      def valid_for_all_locales?
        locales.map do |locale|
          valid?(locale: locale)
        end.all?
      end

      def errors_for_all_locales
        @errors
      end
    end
  end
end
