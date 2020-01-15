require 'http'

module ContentfulLite
  class Asset
    include CommonSysData

    attr_reader :title, :description, :file_name, :content_type, :url, :file_details

    def initialize(raw)
      super(raw)
      @title = raw['fields']['title']
      @description = raw['fields']['description'] || ''
      @file_name = raw['fields']['file']['fileName']
      @content_type = raw['fields']['file']['contentType']
      @url = raw['fields']['file']['url']
      @file_details = raw['fields']['file']['details']
    end

    def contentful_link
      "https://app.contentful.com/spaces/#{space_id}/assets/#{id}"
    end
  end
end
