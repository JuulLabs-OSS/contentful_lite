require 'http'

module ContentfulLite
  class Client
    class RequestError < StandardError
      attr_reader :response, :body

      def initialize(response, body)
        @response = response
        @body = body
        super(body['sys'] && body['sys']['type'] == 'Error' ? "#{body['sys']['id']}: #{body['message']}" : "Invalid Contentful Response: #{body}")
      end
    end

    class NotFoundError < RequestError; end

    attr_reader :space_id, :environment, :preview

    # Creates the Contentful Client
    # @param space_id [String] the Contentful Space Id you want to connect to.
    # @param access_token [String] The secret access token to access the api
    # @param environment [String, nil] To allow querying to a non-master environment
    # @param preview [Boolean] True if you want to get draft entries
    def initialize(space_id:, access_token:, environment: nil, preview: false)
      @space_id = space_id
      @environment = environment
      @preview = preview
      @access_token = access_token
    end

    # Gets an array of entries from Contentful API
    # @param query [Hash] any query params accepted by Contentful API
    # @return [ContentfulLite::EntriesArray]
    def entries(query = {})
      ContentfulLite::EntriesArray.new(request(:entries, query))
    end

    # Gets a single entry from Contentful API
    # @param id [String] Unique id of the Contentful entry
    # @param query [Hash] any query params accepted by Contentful API
    # @return [ContentfulLite::Entry]
    def entry(id, query = {})
      parse_entry request("entries/#{id}", query)
    end

    # Gets a single asset from Contentful API
    # @param id [String] Unique id of the Contentful asset
    # @param query [Hash] any query params accepted by Contentful API
    # @return [ContentfulLite::Asset]
    def asset(id, query = {})
      ContentfulLite::Asset.new(request("assets/#{id}", query))
    end

    # Gets an array of assets from Contentful API
    # @param query [Hash] any query params accepted by Contentful API
    # @return [ContentfulLite::AssetsArray]
    def assets(query = {})
      ContentfulLite::AssetsArray.new(request(:assets, query))
    end

    # Build an entry resource from a raw Contentful API response
    # @param raw [Hash] a JSON parsed response from Contentful API
    # @return [ContentfulLite::Entry,ContentfulLite::Asset,ContentfulLite::DeletedEntry]
    def build_resource(raw)
      case raw['sys']['type']
      when 'Entry'
        parse_entry(raw)
      when 'Asset'
        ContentfulLite::Asset.new(raw)
      when 'DeletedEntry'
        ContentfulLite::DeletedEntry.new(raw)
      end
    end

    private

    def parse_entry(hash)
      klass = ContentfulLite::Entry.get_class(hash['sys']['contentType']['sys']['id'])
      klass.new(hash)
    end

    def create_url(endpoint)
      "https://#{preview ? 'preview' : 'cdn'}.contentful.com/spaces/#{space_id}/" +
        ( environment.nil? ? '' : "environments/#{environment}/" ) +
        endpoint.to_s
    end

    def request(endpoint, parameters)
      parameters.transform_keys!(&:to_s)
      parameters.transform_values! { |value| value.is_a?(::Array) ? value.join(',') : value }
      response = HTTP[request_headers].get(create_url(endpoint), params: parameters)
      body = response.to_s
      body = Zlib::GzipReader.new(StringIO.new(body)).read if response.headers['Content-Encoding'].eql?('gzip')
      JSON.parse(body).tap do |parsed|
        raise error_class(response.status).new(response, parsed) if response.status != 200
      end
    rescue JSON::ParserError
      raise error_class(response.status).new(response, body)
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
