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

    def self.attributes_from_color_data(color_data, mask_data)
      image = Image.from_blob(color_data, WIDTH, HEIGHT, caching: true)

      # Merge in the alpha values from the mask-data, if any.
      mask_array = mask_data.unpack("C*")
      image.each do |c, x, y|
        # Mask is 1 for transparent; 0 for opaque.
        if mask_array[x + y * WIDTH] == 1
          c[0..3] = [0, 0, 0, 0]
        end
      end

      crop_box = image.auto_crop_box(color: :alpha)
      crop_box.width = 1 if crop_box.width == 0
      crop_box.height = 1 if crop_box.height == 0
      image = image.crop crop_box

      @@tmp_image = image

      { image: image, x_offset: crop_box.x, y_offset: crop_box.y }
    end

    def self.attributes_from_data(data, attributes = {})
      version, offset = read_version(data)

      color_data = data[offset, COLOR_DATA_SIZE]

      offset += COLOR_DATA_SIZE

      mask_data = data[offset, AREA]
      offset += AREA

      attributes.merge! attributes_from_color_data(color_data, mask_data)
      
      super(data[offset..-1], attributes)
    end

    def self.default_attributes(attributes = {})
      attributes[:x_offset] = 0
      attributes[:y_offset] = 0

      super(attributes)
    end

    public
    def draw_on_image(canvas, x, y, opacity, glow)
      return if opacity == 0

      img = image
      if opacity < 255
        img = img.dup
        img.rect 0, 0, img.width - 1, img.height - 1, fill: true, color_control: { mult: [1, 1, 1, opacity  / 255.0], sync_mode: :no_sync }
      end

      canvas.splice(img, x + x_offset, y + y_offset, :alpha_blend => true)
    end

    public
    def to_tile
      Tile.generate(name: name, image: image, uid: uid)
    end
  end
end