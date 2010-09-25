require_relative "image_block_resource"

module RSiD
  # A 16x16 image without transparency, that is contained within a room.
  class Tile < ImageBlockResource
    has_many :tile_layers
    has_many :rooms, through: :tile_layers

    set_primary_key :uid

    DEFAULT_COLOR = [0, 0, 0, 1]

    protected
    def self.image_from_color_data(color_data)
      image = Image.from_blob(color_data, WIDTH, HEIGHT)
      @@tmp_image = image

      image
    end

    def self.attributes_from_data(data, attributes = {})
      version, offset = read_version(data)

      attributes[:image] = image_from_color_data(data[offset, COLOR_DATA_SIZE])

      offset += COLOR_DATA_SIZE

      super(data[offset..-1], attributes)
    end

    public
    def draw_on_image(canvas, x, y)
      canvas.splice(image, x, y)
    end

    public
    def to_sprite
      Sprite.generate(image: image, name: name, uid: uid)
    end
  end
end