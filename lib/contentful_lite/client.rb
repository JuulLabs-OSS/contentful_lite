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

    private

    def create_url(endpoint)
      base = "https://#{preview ? 'preview' : 'cdn'}.contentful.com/spaces/#{space_id}/" +
        ( environment.nil? ? '' : "environments/#{environment}/" ) +
        endpoint.to_s
    end

    def request(endpoint, parameters)
      parameters.transform_keys!(&:to_s)
      parameters.transform_values{ |value| value.is_a?(::Array) ? value.join(',') : value }
      response = HTTP[request_headers].get(create_url(endpoint), params: parameters)
    end

    def request_headers
      {
        'Authorization' => "Bearer #{@access_token}",
        'Content-Type' => 'application/vnd.contentful.delivery.v1+json',
        'Accept-Encoding' => 'gzip'
      }
    end
  end
end
