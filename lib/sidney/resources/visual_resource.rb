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

    IMAGE_EXTENSION = 'png'

    public
    def image_path
      File.join(IMAGE_CACHE_DIR, type, "#{id}.#{IMAGE_EXTENSION}")
    end

    public
    def thumbnail_path
      File.join(THUMBNAIL_CACHE_DIR, type, "#{id}.#{IMAGE_EXTENSION}")
    end

    public
    def load_image
      file_name = image_path
      if File.exists? file_name
        Image.new($window, file_name, false, :caching => true)
      else
        nil
      end
    end

    public
    def load_thumbnail
      file_name = thumbnail_path
      if File.exists? file_name
        Image.new($window, file_name)
      else
        nil
      end
    end

    # Caches the image and thumbnail onto the disk.
    public
    def cache_image(image)
      FileUtils.mkdir_p File.dirname(image_path)
      FileUtils.mkdir_p File.dirname(thumbnail_path)

      if image.is_a? Devil::Image
        @@cached_images[id] = image.flip.to_gosu($window)
        cache_devil_image(image.flip)
        image.free
      else
        @@cached_images[id] = image
        image.as_devil { |devil| cache_devil_image(devil) }
      end

      @@cached_images[id]
    end

    public
    def cache_devil_image(devil)
      # Save the image itself.
      devil.save(image_path)
      # Make it into a thumb (pixelised scaling).
      devil.thumbnail(THUMBNAIL_SIZE, filter: Devil::NEAREST)
      # Save the thumbnail.
      devil.save(thumbnail_path)
      # The thumbnail version will be the one returned.
      @@cached_thumbnails[id] = devil.flip.to_gosu($window)
    end

    public
    def image
      @@cached_images[id] ||= load_image || cache_image(create_image)
    end

    def thumbnail
      @@cached_thumbnails[id] ||= load_thumbnail
    end

    # Force any cached images to be re-drawn.
    def redraw
      File.delete image_path if File.exists? image_path
      @@cached_images.delete id
      File.delete thumbnail_path if File.exists? thumbnail_path
      @@cached_thumbnails.delete id
      image # Force redraw now, in update, not in draw later.
    end
  end
end