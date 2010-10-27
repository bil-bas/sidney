# encoding: utf-8

require_relative 'state_object'

module Sidney
  class StateObjectLayer < ActiveRecord::Base   
    belongs_to :scene
    belongs_to :state_object

    BUBBLE_FONT_SIZE = 8
    BUBBLE_INITIAL_WIDTH = 80
    BUBBLE_PADDING_X = 3
    BUBBLE_PADDING_Y = 2
    BUBBLE_LINE_SPACING = -1

    attr_writer :selected, :dragging
    def dragging?; @dragging; end
    def selected?; @selected; end
    def hide!; @visible = false; end
    def show!; @visible = true; end
    def visible?; @visible; end
    def speaking?; not @bubble.nil?; end

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
      @bubble = false
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
    def toggle_speech_bubble
      unless @bubble
        @bubble = TextArea.new(nil, width: BUBBLE_INITIAL_WIDTH, font_size: BUBBLE_FONT_SIZE,
                               padding_x: BUBBLE_PADDING_X, padding_y: BUBBLE_PADDING_Y,
                               line_spacing: BUBBLE_LINE_SPACING, editable: true, z: ZOrder::BUBBLE)
      end

      if @bubble.focused?
        @bubble.publish :blur
        @bubble = nil if @bubble.text.empty?
      else
        @bubble.publish :focus
      end

      nil
    end

    public
    def draw
      @visible = true unless defined? @visible
      if @visible and object = state_object
        object.draw(x, y, alpha)
        if speaking?
          $window.translate(x + object.image.width * 2, y - object.image.height * 2) do
            @bubble.draw
          end
        end
        if @selected
          object.draw_outline(x, y)
          object.draw_anchor(x, y)
        end
      end

      nil
    end

    public
    def draw_layers
      state_object.draw_layers(x, y)
      state_object.draw_anchor(x, y)

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