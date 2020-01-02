require 'http'

module ContentfulLite
  class Client
    class RequestError < StandardError
      def initialize(response, body)
        @response = response
        @body = body
      end
    end
    class NotFoundError < RequestError; end
    attr_reader :space_id, :environment, :preview

    def initialize(space_id:, access_token:, environment: nil, preview: false)
      @space_id = space_id
      @environment = environment
      @preview = preview
      @access_token = access_token
    end

    def entries(query = {})
      request(:entries, query)
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
      body = response.to_s
      body = Zlib::GzipReader.new(StringIO.new(body)).read if response.headers['Content-Encoding'].eql?('gzip')
      JSON.parse(body).tap do |parsed|
        raise error_class(response.status).new(response, parsed) if response.status != 200
      end
    end

    def request_headers
      {
        'Authorization' => "Bearer #{@access_token}",
        'Content-Type' => 'application/vnd.contentful.delivery.v1+json',
        'Accept-Encoding' => 'gzip'
      }
    end

    def error_class(status)
      status == 404 ? NotFoundError : RequestError
    end
  end
end
