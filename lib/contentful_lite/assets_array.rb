module ContentfulLite
  class AssetsArray < BaseArray
    # @param raw [Hash] raw response from Contentful API
    # @api private
    def initialize(raw)
      super(raw)

      # Create the array of asset objects
      @items.collect! { |item| ContentfulLite::Asset.new(item) }
    end
  end
end
