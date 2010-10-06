require_relative 'visual_resource'

require_relative 'sprite_layer'

module RSiD
  class StateObject < VisualResource   
    has_many :sprite_layers
    has_many :sprites, through: :sprite_layers

    has_many :object_layers
    has_many :scenes, through: :object_layers
    
    WIDTH = Sprite::WIDTH * 13
    HEIGHT = Sprite::HEIGHT * 13

    CURRENT_VERSION = 3

    def num_layers
      sprite_layers.count
    end

    def self.current_version
      CURRENT_VERSION
    end

    def initialize(options)
      if options[:version] and options[:layer_data]
        @version = options[:version]
        options.delete(:version)
        @layer_data = options[:layer_data]
        options.delete(:layer_data)
      else
        raise ArgumentError.new
      end

      super(options)
    end
    
    def self.attributes_from_data(data, attributes = {})
      version, offset = read_version(data)
      attributes[:version] = version

      num_layers = data[offset, 1].unpack("C")[0]
      offset += 1

      layer_size = SpriteLayer.data_size(version)

      attributes[:layer_data] = data[offset, num_layers * layer_size]
      offset += num_layers * layer_size

      attributes[:anchor_x] = Sprite::WIDTH * 6
      attributes[:anchor_y] = Sprite::HEIGHT * 6

      super(data[offset..-1], attributes)
    end

    def self.default_attributes(attributes = {})
      attributes[:version] = CURRENT_VERSION
      attributes[:layer_data] = ''

      attributes[:anchor_x] = Sprite::WIDTH * 6
      attributes[:anchor_y] = Sprite::HEIGHT * 6

      super(attributes)
    end

    def create_or_update
      if @version and @layer_data
        layer_size = SpriteLayer.data_size(@version)
        (0...@layer_data.size).step(layer_size) do |offset|
          layer = SpriteLayer.new(id, @version, @layer_data[offset, layer_size])
          layer.save!
        end
        @version = @layer_data = nil
      end
      
      super
    end

    def to_binary
      data = [
        MAGIC_CODE,
        CURRENT_VERSION,
      ].pack("a*C")

      if @layer_data
        # TODO: Won't work for old versions
        #raise Exception.new if @version < CURRENT_VERSION
        layer_size = SpriteLayer.data_size(@version)
        data += [@layer_data.length / layer_size].pack("C")
        data += @layer_data
      else
        layers = SpriteLayer.where(state_object_id: id)
        data += [layers.count].pack("C")
        data += layers.map { |layer| layer.to_binary }.join
      end

      data + super
    end

    def create_image
      img = Image.create(WIDTH, HEIGHT)

      # Force glow only if ALL sprites glow (only change it if the object glow is unset).
      set_glows = (not glows?)
      sprite_layers.each do |layer|
        layer.draw_on_image(img, Sprite::WIDTH * 6, Sprite::HEIGHT * 5)

        set_glows &&= layer.glows?
      end

      self.glows = true if set_glows

      crop_box = img.auto_crop_box
      crop_box.width = 1 if crop_box.width == 0
      crop_box.height = 1 if crop_box.height == 0
      self.x_offset = crop_box.x - Sprite::WIDTH * 6
      self.y_offset = crop_box.y - Sprite::HEIGHT * 10
      img = img.crop crop_box

      update # Ensure that the values for x/y offsets are updated.

      img
    end

    public
    def draw(x, y, opacity)
      return if opacity == 0

      color = Gosu::Color.from_rgba(255, 255, 255, opacity)
      drawing_mode = glows? ? :additive : :default

      image.draw x + x_offset, y + y_offset, Sidney::ZOrder::SCENE, 1, 1, color, drawing_mode

      nil
    end

    public
    def draw_outline(x, y)
      image.redraw_outline unless image.outline
      image.outline.draw(x_offset + x - 1, y_offset + y - 1, Sidney::ZOrder::OUTLINE, 1, 1, Color.from_rgba(255, 255, 0, 155))

      $window.draw_box x, y + 16, 16, 1, Sidney::ZOrder::OUTLINE, nil, Color.from_rgba(0, 255, 0, 155)

      nil
    end

    public
    def rect
      Rect.new(x_offset, y_offset, image.width, image.height)
    end

    public
    def hit?(x, y)
      pixel = image.get_pixel(x - x_offset, y - y_offset)
      pixel and pixel[3] != 0
    end
  end
end