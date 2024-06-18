module ContentfulLite
  class EntriesArray < BaseArray
    # @param raw [Hash] raw response from Contentful API
    # @api private
    def initialize(raw)
      super(raw)

      # Collect arrays of missing (unresolvable) links
      @errors = raw.fetch('errors', []).collect! { |error| error.fetch('details', {}) }.each_with_object({}) do |error_detail, hash|
        type = error_detail['linkType'].downcase.to_sym
        hash[type] ||= []
        hash[type] << error_detail['id']
      end

      # Create the array of asset objects
      @assets = hash_by_id(
        raw.fetch('includes', {}).fetch('Asset', [])
      ).transform_values! { |asset| ContentfulLite::Asset.new(asset) }

      # Now parse the entries, this is the tricky part
      @entries = {}
      @raw_entries = hash_by_id(
        raw.fetch('items', []) + raw.fetch('includes', {}).fetch('Entry', [])
      )
      @items.collect! { |item| build_entry(item['sys']['id']) }
    end

    private

    def solve_link(value)
      if value.is_a?(Array)
        value.collect! { |link| solve_link(link) }.tap(&:compact!)
      elsif value.is_a?(ContentfulLite::Link)
        return nil if @errors.fetch(value.type, []).include?(value.id)

        (value.type == :asset ? @assets[value.id] : build_entry(value.id)) || value
      else
        value
      end
    end

    def hash_by_id(arr)
      arr.each_with_object({}) do |element, hash|
        hash[element['sys']['id']] = element
      end
    end

    def build_entry(id)
      @entries[id] || begin
        hash = @raw_entries.delete(id)
        return nil if hash.nil?

        klass = ContentfulLite::Entry.get_class(hash['sys']['contentType']['sys']['id'])
        @entries[id] = klass.new(hash)
        @entries[id].localized_fields.each_value do |fields|
          fields.transform_values! { |field| solve_link(field) }
        end
        @entries[id]
      end
    end
  end
end
