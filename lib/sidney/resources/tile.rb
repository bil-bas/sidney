require_relative "image_block_resource"

module RSiD
  # A 16x16 image without transparency, that is contained within a room.
  class Tile < ImageBlockResource
    has_many :tile_positions
    has_many :rooms, through: :tile_positions

    set_primary_key :uid

    DEFAULT_COLOR = [0, 0, 0, 255]

    def self.attributes_from_data(data, attributes = {})
      version, offset = read_version(data)

      attributes[:image] = image_from_color_data(data[offset, COLOR_DATA_SIZE]).to_blob
      offset += COLOR_DATA_SIZE

      super(data[offset..-1], attributes)
    end

    def self.default_attributes(attributes = {})
      attributes[:image] = DEFAULT_COLOR.pack('C*') * AREA

      super(attributes)
    end

    # Converting to a sprite, we assume all pixels are opaque
    def to_sprite
      Sprite.generate(image: image, name: name)
    end
  end
end