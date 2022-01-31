module ContentfulLite
  # A link to any type of contentful entity
  class Link
    # The unique id of the linked entity
    attr_reader :id
    # The type of the linked entity
    attr_reader :type

    # @param input [ContentfulLite::CommonData, Hash] data to build the instance
    # @api private
    def initialize(input)
      if input.is_a?(ContentfulLite::CommonData)
        @id = input.id
        @type = input.sys['type'].downcase.to_sym
      else
        @type = input['sys']['linkType'].downcase.to_sym
        @id = input['sys']['id']
      end
    end

    # Equality comparison
    # @param other [Object] the object to compare
    # @return [Boolean] true if other is ContentfulLite::Link with same id and type
    def ==(other)
      self.class == other.class && type == other.type && id == other.id
    end

    # Provided for compatibility with Rails JSON serializer
    # @return [Hash] a Hash representation of the link, to be formated as JSON
    def as_json(**)
      {
        'sys' => {
          'type' => "Link",
          'linkType' => type.to_s.capitalize,
          'id' => id
        }
      }
    end
  end
end
