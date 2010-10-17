require_relative 'sprite'

module Sidney
  # Sprite layer within a StateObject.
  class SpriteLayer < ActiveRecord::Base    
    belongs_to :state_object
    belongs_to :sprite

    DEFAULT_ALPHA = 255

    GLOW_ENABLED = 1
    GLOW_DISABLED = 0
    DEFAULT_GLOW = GLOW_ENABLED

    attr_writer :selected, :dragging
    def dragging?; @dragging; end
    def selected?; @selected; end
    def hide!; @visible = false; end
    def show!; @visible = true; end
    def visible?; @visible; end

    def post_create
      @dragging = false
      @selected = false
      @visible = true
    end

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

      y = -y - 16

      super(state_object_id: state_object_id, sprite_id: sprite_id, x: x, y: y, alpha: alpha, glows: glows)
    end

    def to_binary
      glow_int = glows? ? GLOW_ENABLED : GLOW_DISABLED
      [sprite_id, x, y, alpha, glow_int].pack("H12ccCC")
    end

    def draw_on_image(image, x, y)
      if object = sprite
        object.draw_on_image(image, x + self.x, y + self.y, alpha, glows)
      end
      
      image
    end

    def draw(x, y)
      @visible = true unless defined? @visible
      if @visible and object = sprite
        object.draw(x + self.x, y + self.y, alpha, glows)
        object.draw_outline(x + self.x, y + self.y) if @selected
      end

      nil
    end

    public
    def rect
      rect = sprite.rect
      rect.x += x
      rect.y += y
      rect
   end

    def hit?(x, y)
      if object = sprite
        object.hit?(x - self.x, y - self.y)
      else
        false
      end
    end

    public
    def ==(other)
      other.is_a? self.class and
        sprite_id == other.sprite_id and
        state_object_id == other.state_object_id and
        x == other.x and y == other.y and
        glows? == other.glows? and alpha == other.alpha
    end
  end
end