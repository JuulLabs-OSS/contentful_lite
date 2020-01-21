module ContentfulLite
  class BaseArray < Delegator
    attr_reader :total, :skip, :limit

    def initialize(raw)
      @total = raw['total']
      @skip = raw['skip']
      @limit = raw['limit']
      @items = raw.fetch('items', [])
    end

    def __getobj__
      @items
    end
  end
end
