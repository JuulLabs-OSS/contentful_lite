module ContentfulLite
  class Link
    attr_reader :id, :type

    def initialize(input)
      if input.is_a?(ContentfulLite::CommonData)
        @id = input.id
        @type = input.sys['type'].downcase.to_sym
      else
        @type = input['sys']['linkType'].downcase.to_sym
        @id = input['sys']['id']
      end
    end

    def ==(other)
      self.class == other.class && type == other.type && id == other.id
    end

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
