module ContentfulLite
  class DeletedEntry < Entry
    # Not implemented, provided for compatibility reasons
    # @raise NotImplementedError
    # @api private
    def contentful_link
      raise NotImplementedError.new('contentful_link is not available for deleted entries')
    end
  end
end
