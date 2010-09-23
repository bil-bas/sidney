require_relative "image_block_resource"

module RSiD
  # A 16x16 image with transparency, that is contained within an object.
  class Sprite < ImageBlockResource    
    has_many :sprite_layers
    has_many :state_objects, through: :sprite_layers

    set_primary_key :uid

    TRANSPARENT = 1
    OPAQUE = 0
    
    DEFAULT_TRANSPARENCY = TRANSPARENT

    DEFAULT_COLOR = [0, 0, 0, 0]

    def self.attributes_from_data(data, attributes = {})
      version, offset = read_version(data)

      color_data = data[offset, COLOR_DATA_SIZE]

      offset += COLOR_DATA_SIZE

      mask_data = data[offset, AREA]
      offset += AREA

      attributes[:image] = image_from_color_data(color_data, mask_data)
      
      super(data[offset..-1], attributes)
    end

    public
    def draw_on_image(canvas, offset_x, offset_y, opacity, glow)
      color_proc = if opacity < 255
        opacity /= 255.0
        lambda { |c| c[3] = opacity unless c[3] == 0; c }
      else
        nil
      end

      canvas.splice(image, offset_x, offset_y, :alpha_blend => true, :color_control => color_proc, :mode => glow ? :additive : :copy)
    end

    public
    def to_tile
      Tile.generate(name: name, image: image, uid: uid)
    end
  end
end