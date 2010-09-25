require_relative 'resource'


module RSiD 
  class VisualResource < Resource
    @abstract_class = true

    @@cached_images = Hash.new
    @@cached_thumbnails = Hash.new

    IMAGE_CACHE_DIR = File.join(ROOT_PATH, 'resources', 'images')
    FileUtils.mkdir_p IMAGE_CACHE_DIR

    THUMBNAIL_CACHE_DIR = File.join(ROOT_PATH, 'resources', 'thumbnails')
    FileUtils.mkdir_p THUMBNAIL_CACHE_DIR
    THUMBNAIL_SIZE = 16

    public
    def load_image
      file_name = File.join(IMAGE_CACHE_DIR, "#{uid}.png")
      if File.exists? file_name
        Image.new($window, file_name, false, :caching => true)
      else
        nil
      end
    end

    public
    def load_thumbnail
      file_name = File.join(THUMBNAIL_CACHE_DIR, "#{uid}.png")
      if File.exists? file_name
        Image.new($window, file_name)
      else
        nil
      end
    end

    # Caches the image and thumbnail onto the disk.
    public
    def cache_image(image)
      @@cached_images[uid] = image

      image.as_devil do |devil|
        # Save the image itself.
        devil.save(File.join(IMAGE_CACHE_DIR, "#{uid}.png"))
        # Make it into a thumb.
        devil.thumbnail(THUMBNAIL_SIZE, filter: Devil::NEAREST)
        # Save the thumbnail.
        devil.save(File.join(THUMBNAIL_CACHE_DIR, "#{uid}.png"))
        # The thumbnail version will be the one returned.
        @@cached_thumbnails[uid] = devil.to_gosu($window)
      end

      image
    end

    public
    def image
      @@cached_images[uid] ||= load_image || cache_image(create_image)
    end

    def thumbnail
      @@cached_thumbnails[uid] ||= load_thumbnail || create_thumbnail
    end
  end
end