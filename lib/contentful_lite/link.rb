module ContentfulLite
  class Link
    attr_reader :id, :type

    def initialize(raw)
      @type = raw['sys']['linkType'].downcase.to_sym
      @id = raw['sys']['id']
    end

    def ==(other)
      self.class == other.class && type == other.type && id == other.id
    end
  end
end
