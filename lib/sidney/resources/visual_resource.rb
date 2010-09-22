require_relative 'resource'


module RSiD 
  class VisualResource < Resource
    @abstract_class = true

    @@cached_images = Hash.new

    def image
      @@cached_images[uid] ||= create_image
    end
  end
end