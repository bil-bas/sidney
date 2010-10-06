require_relative 'visual_resource'
require_relative 'room'
require_relative 'state_object_layer'


module RSiD
  class Scene < VisualResource  
    belongs_to :room

    has_many :state_object_layers
    has_many :state_objects, through: :state_object_layers

    serialize :tint

    CURRENT_VERSION = 2
    DEFAULT_OBJECT_ZERO_FROZEN = false
    DEFAULT_TINT = [0, 0, 0, 0]

    def self.current_version
      CURRENT_VERSION
    end

    def tint
      Gosu::Color.rgba(*self[:tint])
    end

    def tint=(color)
      self[:tint] = case color
      when Gosu::Color
        [color.red, color.blue, color.green, color.alpha]
      when Array
        color
      end
    end

    protected
    def initialize(options)
      if options[:state_object_layers]
        @state_object_layers = options[:state_object_layers]
        options.delete(:state_object_layers)
      else
        raise ArgumentError.new
      end

      super(options)
    end

    public
    def create_or_update
      if @state_object_layers
         @state_object_layers.each do |layer|
          layer.scene_id = id
          layer.save!
        end
        @state_object_layers = nil
      end

      super
    end

    def self.attributes_from_data(data, attributes = {})
      version, offset = read_version(data)

      attributes[:room_id] = data[offset, UID_NUM_BYTES].unpack(UID_PACK)[0]
      offset += UID_NUM_BYTES


      room_alpha, object_zero_frozen, num_objects = data[offset, 3].unpack("CCC")
      offset += 3
      attributes[:tint] = [0, 0, 0, 255 - room_alpha]

      object_data_length = StateObjectLayer.data_length(version)

      object_layers = []
      (0...num_objects).each do |z|
        object_data = data[offset + (z * object_data_length), object_data_length]
        object_layers.push StateObjectLayer.new(nil, version, object_data, z)
      end

      # All layers have locking now, so if the player is specifically frozen (due to old version),
      # overwrite that default value.
      object_layers[0].locked = object_zero_frozen unless object_layers.empty?
      
      attributes[:state_object_layers] = object_layers
      offset += object_data_length * num_objects

      super(data[offset..-1], attributes)
    end

    def self.default_attributes(attributes = {})
      attributes[:room_id] = Room.default.id unless attributes[:room_id]
      attributes[:tint] = DEFAULT_TINT unless attributes[:tint]
      attributes[:state_object_layers] = [] # TODO: create default player object.
      
      super(attributes)
    end

    protected
    def to_binary
      layers = @state_object_layers ? @state_object_layers : state_object_layers.order(:z)

      data = [
        room_id,
        tint.red, tint.green, tint.blue, tint.alpha,
      ].pack("#{UID_PACK}CCCC")

      data += layers.map { |o| o.to_binary }.join

      data + super
    end

    protected
    def create_image()
      image = Image.create(Room::WIDTH, Room::HEIGHT)
      $window.render_to_image(image) { draw }
    end

    # Layers is draw order (back to front).
    public
    def cached_layers
      unless @cached_layers
        @cached_layers = state_object_layers.includes(:state_object).all
        reorder_layer_cache
      end

      @cached_layers
    end

    public
    def clear_layer_cache
      @cached_layers = nil
    end

    public
    def reorder_layer_cache
      @cached_layers = @cached_layers.sort_by.with_index {|k, i| [k.y, k.locked? ? 0 : 1, k.z, i] }
    end

    public
    def draw
      background = room.image
      background.draw(0, 0, Sidney::ZOrder::SCENE)

      # Draw foreground objects.
      cached_layers.each { |layer| layer.draw }

      # Overlay a filter.
      if tint.alpha > 0
        $window.draw_box(0, 0, background.width, background.height, Sidney::ZOrder::SCENE_FILTER, nil, tint)
      end

      nil
    end

    public
    def hit_object(x, y)
      cached_layers.reverse_each do |layer|
        return layer if layer.hit?(x, y)
      end

      nil
    end
  end
end