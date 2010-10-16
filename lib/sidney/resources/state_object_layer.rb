require_relative 'state_object'

module RSiD
  class StateObjectLayer < ActiveRecord::Base   
    belongs_to :scene
    belongs_to :state_object

    attr_writer :selected, :dragging
    def dragging?; @dragging; end
    def selected?; @selected; end
    def hide!; @visible = false; end
    def show!; @visible = true; end
    def visible?; @visible; end

    def self.data_length(version)
      case version
        when 1
          Resource::UID_NUM_BYTES + 8 + 8 + 1 + 1
        when 2
          # Added speech box toggle and object locking.
          Resource::UID_NUM_BYTES + 8 + 8 + 1 + 1 + 1 + 1
        else
          raise Exception(version.to_s)
        end
    end

    protected
    def initialize(scene_id, version, data, z_depth)
      state_object_id = data.unpack(Resource::UID_PACK)[0]
      offset = Resource::UID_NUM_BYTES

      z = z_depth

      x, y = data[offset, 8].unpack("NN")
      x += Room::IMPORT_X_OFFSET * Tile::WIDTH
      y = (Room::IMPORT_HEIGHT * Tile::HEIGHT) - y
      y += Room::IMPORT_Y_OFFSET * Tile::HEIGHT
      offset += 8

      speech_offset_x, speech_offset_y = data[offset, 8].unpack("NN")
      offset += 8

      speech_flipped = data[offset].unpack("C")[0] == 1
      offset += 1

      if version >= 2
        speech_box = data[offset].unpack("C")[0] == 1
        offset += 1
        locked = data[offset].unpack("C")[0] == 1
        offset += 1
      else
        speech_box = locked = false
      end

      alpha = data[offset].unpack("C")[0]
      
      super(scene_id: scene_id,
            state_object_id: state_object_id,
            alpha: alpha,
            locked: locked,
            x: x, y: y, z: z,
            speech_box: speech_box,
            speech_flipped: speech_flipped,
            speech_offset_x: speech_offset_x,
            speech_offset_y: speech_offset_y
      )
    end

    public
    def post_create
      @dragging = false
      @selected = false
      @visible = true
    end

    public
    def to_binary
      [
        state_object_id,
        x, y,
        speech_offset_x, speech_offset_y,
        speech_flipped ? 1 : 0,
        speech_box ? 1 : 0,
        locked ? 1 : 0,
        alpha
      ].pack("#{Resource::UID_PACK} NNNN CCCC")
    end

    public
    def draw
      @visible = true unless defined? @visible
      if @visible and object = state_object
        object.draw(x, y, alpha)
        object.draw_outline(x, y) if @selected
      end

      nil
    end

    public
    def draw_layers
      state_object.draw_layers(x, y)

      nil
    end

    public
    def rect
      rect = state_object.rect
      rect.x += x
      rect.y += y
      rect
   end

    public
    def hit?(x, y)
      state_object.hit?(x - self.x, y - self.y)
    end

    public
    def hit_sprite(x, y)
      state_object.hit_sprite(x - self.x, y - self.y)
    end

    public
    def ==(other)
      other.is_a? self.class and
              scene_id == other.scene_id and
              state_object_id == other.state_object_id and
              x == other.x and y == other.y and z = other.z and
              alpha == other.alpha and locked? == other.locked? and
              speech_offset_x == other.speech_offset_x and speech_offset_y == other.speech_offset_y and
              speech_flipped? == other.speech_flipped? and speech_box? == other.speech_box?
    end
  end
end