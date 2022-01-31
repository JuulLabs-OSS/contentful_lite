require 'http'

module ContentfulLite
  class Asset
    include CommonData

    # Gets the URL to view/edit the entry on Contentful webapp
    # @return [String]
    def contentful_link
      "https://app.contentful.com/spaces/#{space_id}/assets/#{id}"
    end

    # @api private
    # @!macro [attach] asset_attribute
    #   Returns the $1 attribute of the Contentful Asset
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
