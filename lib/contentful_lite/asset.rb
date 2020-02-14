require 'http'

module ContentfulLite
  class Asset
    include CommonData

    def contentful_link
      "https://app.contentful.com/spaces/#{space_id}/assets/#{id}"
    end

    def self.asset_attribute(key, path, default: nil)
      define_method(key) do |locale: nil|
        path.inject(fields(locale: locale)) { |hash, path_section| hash.nil? ? nil : hash[path_section] } || default
      end
    end
    private_class_method :asset_attribute

    asset_attribute :title, ['title']
    asset_attribute :description, ['description'], default: ''
    asset_attribute :file_name, ['file', 'fileName']
    asset_attribute :content_type, ['file', 'contentType']
    asset_attribute :url, ['file', 'url']
    asset_attribute :file_details, ['file', 'details']
  end
end
