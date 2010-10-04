require_relative 'visual_resource'
require_relative 'room'
require_relative 'state_object_layer'


module RSiD
  class Scene < VisualResource  
    belongs_to :room

    has_many :state_object_layers
    has_many :state_objects, through: :state_object_layers

    CURRENT_VERSION = 2
    DEFAULT_OBJECT_ZERO_FROZEN = false
    DEFAULT_ROOM_ALPHA = 255

    def self.current_version
      CURRENT_VERSION
    end

    def initialize(options)
      if options[:state_object_layers]
        @state_object_layers = options[:state_object_layers]
        options.delete(:state_object_layers)
      else
        raise ArgumentError.new
      end

      super(options)
    end

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


      room_alpha, object_zero_frozen, num_objects =  data[offset, 3].unpack("CCC")
      offset += 3
      attributes[:room_alpha] = room_alpha

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
      attributes[:room_alpha] = DEFAULT_ROOM_ALPHA unless attributes[:room_alpha]
      attributes[:state_object_layers] = [] # TODO: create default player object.
      
      super(attributes)
    end

    def to_binary
      layers = @state_object_layers ? @state_object_layers : state_object_layers.order(:z)

      data = [
        MAGIC_CODE,
        CURRENT_VERSION,
        room_id,
        room_alpha,
        (layers.first and layers.first.locked) ? 1 : 0,
        layers.size
      ].pack("a*C#{UID_PACK}CCC")

      data += layers.map { |o| o.to_binary }.join

      data + super
    end

    def create_image
      room.image.draw 0, 0, 0 rescue nil

      layers = state_object_layers.order(:z, :y).all

      # Draw foreground objects.
      layers.each { |layer| layer.draw }

      $window.to_devil(0, 0, Room::WIDTH, Room::HEIGHT)
    end

    def draw(x, y)
      @draw_color ||= Color.from_rgba(255, 255, 255, 255)
      @draw_color.alpha = room_alpha
      image.draw(x, y, Sidney::ZOrder::SCENE, 1, 1, @draw_color)
    end

    def hit_object(x, y)
      found = nil

      state_object_layers.order(:z).reverse_each do |layer|
        if layer.hit?(x, y) and (found.nil? or layer.y > found.y)
          found = layer
        end
      end

      found
    end
  end
end