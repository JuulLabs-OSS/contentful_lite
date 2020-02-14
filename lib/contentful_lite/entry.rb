module ContentfulLite
  class Entry
    include CommonData
    include EntryMapping

    attr_reader :content_type_id

    def initialize(raw)
      super(raw)
      @content_type_id = raw['sys']['contentType']['sys']['id']
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
  end
end
