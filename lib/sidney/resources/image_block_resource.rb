require_relative '../gosu_ext'
require 'devil'
require 'devil/gosu'

require_relative 'visual_resource'

module RSiD
  class ImageBlockResource < VisualResource
    @abstract_class = true

    WIDTH = HEIGHT = 16 # 16x16 pixels per tile/sprite.
    AREA = WIDTH * HEIGHT
    COLOR_DATA_SIZE = AREA * 4

    def to_binary
      (uid ? image : @@tmp_image).to_blob + super
    end

    protected
    def self.image_from_color_data(color_data, mask_data = nil)
      image = Image.from_blob(color_data, WIDTH, HEIGHT, caching: !mask_data.nil?)

      # Merge in the alpha values from the mask-data, if any.
      if mask_data
        mask_array = mask_data.unpack("C*")
        image.each do |c, x, y|
          # Mask is 1 for transparent; 0 for opaque.
          if mask_array[x + y * WIDTH] == 1
            c[0..3] = [0, 0, 0, 0]
          end
        end
      end

      @@tmp_image = image

      image
    end

    def self.default_attributes(attributes = {})
      attributes[:image] = Image.from_blob(default_color.pack('C*') * AREA, WIDTH, HEIGHT)
      @@tmp_image = attributes[:image]

      super(attributes)
    end

    protected
    def self.default_color
      self.const_get :DEFAULT_COLOR
    end
  end
end