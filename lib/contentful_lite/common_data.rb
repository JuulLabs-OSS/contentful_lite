require "active_support/core_ext/object/json"
require "active_support/core_ext/hash/keys"

module ContentfulLite
  # Parses data common to all Contentful resources.
  module CommonData
    attr_reader :id, :created_at, :updated_at, :default_locale, :revision, :space_id, :environment_id, :retrieved_at, :locales, :localized_fields, :sys

    # @param raw [Hash] raw response from Contentful API
    # @api private
    def initialize(raw)
      @sys = raw['sys']
      @id = sys['id']
      @created_at = DateTime.parse sys['createdAt']
      @updated_at = DateTime.parse sys['updatedAt']
      @locale = sys['locale']
      @revision = sys['revision']
      @space_id = sys['space']['sys']['id']
      @environment_id = sys['environment']['sys']['id']
      @retrieved_at = DateTime.now

      if locale
        @locales = [locale]
        @localized_fields = { locale => raw['fields'] }
      else
        @locales = raw.fetch('fields', {}).values.collect_concat(&:keys).uniq
        @localized_fields = @locales.each_with_object({}) do |locale, hash|
          hash[locale] = raw['fields'].transform_values { |value| value[locale] }
        end
      end

      @default_locale = @locales.first
    end

    # Provides access to the locale being used to read fields
    def locale
      @locale || @default_locale
    end

    # Sets the locale that will be used to read fields
    # @param value [String] the locale code
    # @raise [StandardError] 'Invalid Locale' for locales not included on the API response
    def locale=(value)
      raise 'Invalid Locale' unless value.in?(locales)

      @locale = value
    end

    # Returns a hash with field => value format using specified locale
    # @param locale [String, nil] the locale that will be used for reading the fields. Defaults to {#locale}
    # @return [Hash]
    def fields(locale: nil)
      @localized_fields.fetch(locale || self.locale, {})
    end

    # Executes a block with {#locale} set to the received locale. Then sets it back
    # to current locale.
    # @param locale [String] the locale to run the block with
    # @yield
    def with_locale(locale)
      old_locale = @locale
      @locale = locale unless locale.nil?
      begin
        yield
      ensure
        @locale = old_locale
      end
    end

    # Gets a ContentfulLite::Link to the entry
    # @return [ContentfulLite::Link] a link to this entry
    def to_link
      ContentfulLite::Link.new(self)
    end

    # Provided for compatibility with Rails JSON serializer
    # @param serialized_ids [Array<String>] Ids already serialized, required for possible mutual references
    # @param options [Hash] Serialization options, only provided for compatibility
    # @return [Hash] a Hash representation of the link, to be formated as JSON
    def as_json(serialized_ids: [], **options)
      return to_link.as_json if serialized_ids.include?(id)

      {
        "sys" => sys,
        "fields" => fields.transform_values do |value|
          if value.respond_to?(:as_json)
            value.as_json(serialized_ids: serialized_ids + [id], **options)
          else
            value
          end
        end
      }
    end
  end
end
