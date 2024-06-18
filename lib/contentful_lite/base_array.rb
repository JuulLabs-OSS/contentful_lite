module ContentfulLite
  class BaseArray < Delegator
    # The total number of items in the result
    attr_reader :total
    # The skip parameter sent to Contentful API for getting this result
    attr_reader :skip
    # The maximum number of resources returned per request
    attr_reader :limit

    # @param raw [Hash] raw response from Contentful API
    # @api private
    def initialize(raw)
      super
      @total = raw['total']
      @skip = raw['skip']
      @limit = raw['limit']
      @items = raw.fetch('items', [])
    end

    # @api private
    def __getobj__
      @items
    end

    # @api private
    def __setobj__(value)
      @items = value
    end
  end
end
