require_relative "image_block_resource"

module RSiD
  # A 16x16 image with transparency, that is contained within an object.
  class Sprite < ImageBlockResource    
    has_many :sprite_layers
    has_many :state_objects, through: :sprite_layers

    set_primary_key :uid
    attr_accessible :mask
    serialize :mask
    
    TRANSPARENT = 1
    OPAQUE = 0
    
    DEFAULT_TRANSPARENCY = TRANSPARENT

    # 256 pixel colours + 256 mask
    MASK_PACK_FORMAT = "C#{AREA}"

    def validate_mask
      errors.add(:mask, "has incorrect size: #{mask.size}") unless mask.size == AREA
    end
    validate :validate_mask

    def self.attributes_from_data(data, attributes = {})
      version, offset = read_version(data)

      color_data = data[offset, COLOR_DATA_SIZE]

      offset += COLOR_DATA_SIZE

      attributes[:mask] = data[offset, AREA].unpack(MASK_PACK_FORMAT)
      offset += AREA

      attributes[:image] = image_from_color_data(color_data, attributes[:mask]).to_blob
      
      super(data[offset..-1], attributes)
    end

    def to_binary
      to_image.to_blob + super
    end

    def to_tile
      Tile.generate(name: name, image: image)
    end
  end
end