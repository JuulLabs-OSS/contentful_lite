module ContentfulLite
  class DeletedEntry < Entry;
    def contentful_link
      raise NotImplementedError.new('contentful_link is not available for deleted entries')
    end
  end
end
