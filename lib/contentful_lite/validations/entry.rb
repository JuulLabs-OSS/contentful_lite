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
      end

      class_methods do
        def validates_included_entry(*attr_names)
          validates_with IncludedEntryValidator, _merge_attributes(attr_names)
        end

        def validates_included_asset(*attr_names)
          validates_with IncludedAssetValidator, _merge_attributes(attr_names)
        end
      end
    end
  end
end
