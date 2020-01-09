require 'http'

module ContentfulLite
  class Entry
    include EntryMapping

    attr_reader :id, :created_at, :updated_at, :locale, :revision, :space_id, :environment_id, :content_type_id, :fields

    def initialize(raw, _links)
      parse_sys(raw['sys'])
      @fields = raw['fields']
    end

    private

    def parse_sys(sys)
      @id = sys['id']
      @created_at = DateTime.parse sys['createdAt']
      @updated_at = DateTime.parse sys['updatedAt']
      @locale = sys['locale']
      @revision = sys['revision']
      @space_id = sys['space']['sys']['id']
      @environment_id = sys['environment']['sys']['id']
      @content_type_id = sys['contentType']['sys']['id']
    end
  end
end
