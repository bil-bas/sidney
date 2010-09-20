require_relative 'state_object'

module RSiD
  class StateObjectLayer < ActiveRecord::Base   
    belongs_to :scene, foreign_key: :scene_uid
    belongs_to :state_object, foreign_key: :state_object_uid

    def scene
      Scene.load(scene_uid)
    end
    
    def state_object
      StateObject.load(state_object_uid)
    end

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
    
    def initialize(scene_uid, version, data, z_depth)
      state_object_uid = data.unpack(Resource::UID_PACK)[0]
      offset = Resource::UID_NUM_BYTES

      z = z_depth

      x, y = data[offset, 8].unpack("NN")
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
      
      super(scene_uid: scene_uid,
            state_object_uid: state_object_uid,
            alpha: alpha,
            locked: locked,
            x: x, y: y, z: z,
            speech_box: speech_box,
            speech_flipped: speech_flipped,
            speech_offset_x: speech_offset_x,
            speech_offset_y: speech_offset_y
      )
    end

    def to_binary
      [
        state_object_uid,
        x, y,
        speech_offset_x, speech_offset_y,
        speech_flipped ? 1 : 0,
        speech_box ? 1 : 0,
        locked ? 1 : 0,
        alpha
      ].pack("#{Resource::UID_PACK} NNNN CCCC")
    end

    def draw_on_image(image)
      state_object.draw_on_image(image, x, y + Sprite::WIDTH)
      image
    end
  end
end