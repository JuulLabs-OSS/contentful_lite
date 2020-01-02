require 'http'

module ContentfulLite
  class Client
    attr_reader :space_id, :environment, :preview

    def initialize(space_id:, access_token:, environment: nil, preview: false)
      @space_id = space_id
      @environment = environment
      @preview = preview
      @access_token = access_token
    end
  end
end
