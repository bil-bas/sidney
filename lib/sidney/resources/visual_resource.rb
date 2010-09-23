require_relative 'resource'


module RSiD 
  class VisualResource < Resource
    @abstract_class = true

    @@cached_images = Hash.new

    IMAGE_CACHE_DIR = File.join(ROOT_PATH, 'resources', 'images')
    FileUtils.mkdir_p IMAGE_CACHE_DIR

    public
    def create_image
      file_name = File.join(IMAGE_CACHE_DIR, "#{uid}.png")
      if File.exists? file_name
        Image.new($window, file_name, false, :caching => true)
      else
        nil
      end
    end

    public
    def cache_image(image)
      @@cached_images[uid] = image
      image.save(File.join(IMAGE_CACHE_DIR, "#{uid}.png"))
    end

    public
    def image
      @@cached_images[uid] ||= create_image
    end
  end
end