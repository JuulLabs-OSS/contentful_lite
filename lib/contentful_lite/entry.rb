module ContentfulLite
  class Entry
    include CommonData
    include EntryMapping
    include Validations::Entry

    # The id for the content type of this entry
    attr_reader :content_type_id

    # @param raw [Hash] raw response from Contentful API
    # @api private
    def initialize(raw)
      super
      @content_type_id = raw['sys']['contentType']['sys']['id']
      @localized_fields.each_value do |fields|
        fields.transform_values! { |value| build_link(value) }
      end
    end

    # Gets the URL to view/edit the entry on Contentful webapp
    # @return [String]
    def contentful_link
      "https://app.contentful.com/spaces/#{space_id}/entries/#{id}"
    end

    # Defines a field existing on the content type. This macro registers the
    # accessor for that field
    # @param attrs [Array<Symbol,String>] The field names
    # @param default [Object, nil] The default value to return if field is not present on API response
    # @param localizable [Boolean] If the field is marked as localizable
    # @example Defines two string localizable localized fields
    #   field_reader :first_name, :last_name, localizable: true
    # @see https://github.com/JuulLabs-OSS/contentful_lite#creating-your-model-classes-with-macros
    def self.field_reader(*attrs, default: nil, localizable: false)
      attrs.each do |k|
        define_method(k) do |locale: nil|
          field = fields(locale: localizable ? locale : default_locale)[k.to_s]
          field.nil? ? default : field
        end
      end
    end

    private

    def build_link(value)
      return value.map!{ |element| build_link(element) } if value.is_a?(Array)
      return value unless value.is_a?(Hash) && value.fetch('sys', {}).fetch('type', '') == 'Link'

      ContentfulLite::Link.new(value)
    end
  end
end
