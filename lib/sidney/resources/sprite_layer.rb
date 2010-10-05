require_relative 'sprite'

module RSiD
  # Sprite layer within a StateObject.
  class SpriteLayer < ActiveRecord::Base    
    belongs_to :state_object
    belongs_to :sprite

    DEFAULT_ALPHA = 255

    GLOW_ENABLED = 1
    GLOW_DISABLED = 0
    DEFAULT_GLOW = GLOW_ENABLED

    def self.data_size(version)
      length = case version
      when 1
        8
      when 2
        9 # Includes alpha
      when 3
        10 # Includes alpha + glow
      else
        raise ArgumentError.new(version.to_s)
      end
    end

    def initialize(state_object_id, version, data)

      sprite_id, x, y, alpha, glow_int = case version
      when 1
        data.unpack("H12cc") + [DEFAULT_ALPHA, DEFAULT_GLOW]
      when 2
        data.unpack("H12ccC") + [DEFAULT_GLOW]
      when 3
        data.unpack("H12ccCC")
      else
        raise ArgumentError.new(version.to_s)    
      end
      
      glows = (glow_int == GLOW_ENABLED)

      super(state_object_id: state_object_id, sprite_id: sprite_id, x: x, y: y, alpha: alpha, glows: glows)
    end

    def to_binary
      glow_int = glows? ? GLOW_ENABLED : GLOW_DISABLED
      [sprite_id, x, y, alpha, glow_int].pack("H12ccCC")
    end

    def draw_on_image(image, x, y)
      if object = sprite
        object.draw_on_image(image, x + self.x, Room::HEIGHT - y - self.y, alpha, glows)
      end
      
      image
    end

    def draw(x, y)
      if object = sprite
        object.draw(x + self.x, Room::HEIGHT - y - self.y, alpha, glows)
      end

      nil
    end

    def hit?(x, y)
      if object = sprite
        object.hit?(x + self.x, Room::HEIGHT - y - self.y)
      else
        false
      end
    end
  end
end