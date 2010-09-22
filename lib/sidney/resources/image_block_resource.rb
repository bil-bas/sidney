require_relative '../gosu_ext'
require 'devil'
require 'devil/gosu'

require_relative 'visual_resource'

module RSiD
  class ImageBlockResource < VisualResource
    @abstract_class = true

    attr_accessible :image

    WIDTH = HEIGHT = 16 # 16x16 pixels per tile/sprite.
    AREA = WIDTH * HEIGHT
    COLOR_DATA_SIZE = AREA * 4

    public
    def to_image
      @cached_image ||= Image.from_blob(image, WIDTH, HEIGHT)
    end

    def to_binary
      image + super
    end

    public
    def draw_on_image(canvas, offset_x, offset_y, opacity = 255, glow = false)
      # TODO: Use opacity parameters.
      canvas.splice(to_image, offset_x, offset_y, chroma_key: :transparent)
    end

    protected
    def self.image_from_color_data(color_data, mask_data = nil)
      image = Image.from_blob(color_data, WIDTH, HEIGHT)

      # Merge in the alpha values from the mask-data, if any.
      if mask_data
        mask_array = mask_data.unpack("C*")
        image.each do |c, x, y|
          # Mask is 1 for transparent; 0 for opaque.
          c[3] = mask_array[x + y * WIDTH] == 0 ? 1 : 0
        end
      end

      Image.from_blob(image.to_blob, WIDTH, HEIGHT)
    end

    protected
    def self.default_color
      DEFAULT_COLOR
    end
  end
end