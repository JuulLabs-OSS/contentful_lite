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

      # @!method self.validates_included_entry(*attr_names, **options)
      #   Adds a validation on one or more fields to ensure it's a reference field
      #   and the values are entries with one of the specified types
      #   @param attr_names [Array<string>] the fields to validate
      #   @param options [Hash] the options Hash
      #   @option options [Array<Class>] :allowed_models the contentful content types that will be allowed
      #   @option options [Boolean] :allow_blank if true it allows the field to be empty
      #   @option options [Boolean] :array if true, the field must be an array of references.
      #     If not, it must be a single reference.
      class_methods do
        def validates_included_entry(*attr_names)
          validates_with IncludedEntryValidator, _merge_attributes(attr_names)
        end
      end

      # @!method self.validates_included_asset(*attr_names, **options)
      #   Adds a validation on one or more fields to ensure it's a reference field
      #   and the values are assets
      #   @param attr_names [Array<string>] the fields to validate
      #   @param options [Hash] the options Hash
      #   @option options [Array<Class>] :type the asset content types that will be allowed
      #   @option options [Boolean] :allow_blank if true it allows the field to be empty
      #   @option options [Boolean] :array if true, the field must be an array of references.
      #     If not, it must be a single reference.
      class_methods do
        def validates_included_asset(*attr_names)
          validates_with IncludedAssetValidator, _merge_attributes(attr_names)
        end
      end

      # Validates all locales
      # @return [boolean] is entry valid across al locales?
      def valid_for_all_locales?
        locales.map do |locale|
          valid?(locale: locale)
        end.all?
      end

      # Gets the error messages for all the locales at once
      # @return [Hash] a hash with locale as keys and errors as values
      def errors_for_all_locales
        @errors
      end
    end
  end
end
