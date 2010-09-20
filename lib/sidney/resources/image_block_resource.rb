require_relative 'visual_resource'

module RSiD
  class ImageBlockResource < VisualResource
    @abstract_class = true

    attr_accessible :image

    WIDTH = HEIGHT = 16 # 16x16 pixels per tile/sprite.
    AREA = WIDTH * HEIGHT
    COLOR_DATA_SIZE = AREA * 4
    DEFAULT_COLOR = Gosu::Color.from_rgb(0, 0, 0)

    public
    def to_image
      @cached_image ||= Image.from_blob($window, image, WIDTH, HEIGHT)
    end

    public
    def draw_on_image(canvas, offset_x, offset_y, opacity = 255, glow = false)
      # TODO: Use opacity parameter.
      canvas.splice(to_image, offset_x, offset_y, chroma_key: :alpha)
    end

    class << self
      protected
      def image_from_color_data(color_data, mask_data = nil)
        image = Image.from_blob($window, color_data, WIDTH, HEIGHT)

        # Merge in the alpha values from the mask-data, if any.
        if mask_data
          mask_array = mask.unpack("C*")
          image.each do |c, x, y|
            c[3] = mask_array[x + y * WIDTH]
          end
        end

        image
      end

      protected
      def default_color
         DEFAULT_COLOR
      end
    end
  end
end