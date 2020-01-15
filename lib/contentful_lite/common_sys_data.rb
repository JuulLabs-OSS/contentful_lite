require 'http'

module ContentfulLite
  module CommonSysData
    attr_reader :id, :created_at, :updated_at, :locale, :revision, :space_id, :environment_id

    def initialize(raw, _links = nil)
      sys = raw['sys']
      @id = sys['id']
      @created_at = DateTime.parse sys['createdAt']
      @updated_at = DateTime.parse sys['updatedAt']
      @locale = sys['locale']
      @revision = sys['revision']
      @space_id = sys['space']['sys']['id']
      @environment_id = sys['environment']['sys']['id']
    end
  end
end