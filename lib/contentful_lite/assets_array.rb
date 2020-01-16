module ContentfulLite
  class AssetsArray < BaseArray
    def initialize(raw)
      super(raw)

      # Create the array of asset objects
      @items.collect! { |item| ContentfulLite::Asset.new(item) }
    end
  end
end
