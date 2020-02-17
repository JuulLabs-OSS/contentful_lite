module ContentfulLite
  class Entry
    include CommonData
    include EntryMapping

    attr_reader :content_type_id

    def initialize(raw)
      super(raw)
      @content_type_id = raw['sys']['contentType']['sys']['id']
      @localized_fields.values.each do |fields|
        fields.transform_values! { |value| build_link(value) }
      end
    end

    def contentful_link
      "https://app.contentful.com/spaces/#{space_id}/entries/#{id}"
    end

    def self.field_reader(*attrs, default: nil)
      attrs.each do |k|
        define_method(k) do |locale: nil|
          fields(locale: locale)[k.to_s] || default
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
