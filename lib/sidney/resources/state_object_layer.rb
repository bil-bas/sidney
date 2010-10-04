require_relative 'state_object'

module RSiD
  class StateObjectLayer < ActiveRecord::Base   
    belongs_to :scene
    belongs_to :state_object

    attr_writer :selected, :dragging
    def dragging?; @dragging; end
    def selected?; @selected; end

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
    
    def initialize(scene_id, version, data, z_depth)
      state_object_id = data.unpack(Resource::UID_PACK)[0]
      offset = Resource::UID_NUM_BYTES

      z = z_depth

      x, y = data[offset, 8].unpack("NN")
      x += Room::IMPORT_X_OFFSET * Tile::WIDTH
      y = (Room::HEIGHT - y) + (Room::IMPORT_Y_OFFSET - 3) * Tile::HEIGHT
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

    def post_create
      @dragging = false
      @selected = false
    end

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
    def draw_on_image(image)
      if object = state_object
        object.draw_on_image(image, x, y, alpha)
      end
      image
    end

    public
    def draw()
      if object = state_object
        object.draw(x, y, alpha)
      end
      nil
    end

    def hit?(x, y)
      state_object.hit?(x - self.x, y - self.x)
    end
  end
end