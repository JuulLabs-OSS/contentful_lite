require 'active_support/concern'

module ContentfulLite
  # @api private
  module EntryMapping
    extend ActiveSupport::Concern

    included do |base_klass|
      base_klass.define_singleton_method(:content_type_id) do |name|
        klass = self
        base_klass.class_eval do
          @mappings ||= {}
          @mappings[name] = klass
        end
      end

      base_klass.define_singleton_method(:get_class) do |content_type_id|
        @mappings ||= {}
        @mappings[content_type_id] || base_klass
      end
    end
  end
end
