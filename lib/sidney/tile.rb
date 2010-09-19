require 'chingu'

module Sidney
class Tile < GameObject
  def initialize(options = {})
    super({center: 0, zorder: ZOrder::BACKGROUND}.merge!(options))
  end

  def draw_to_buffer(buffer, x_offset, y_offset)
    buffer.splice(image, x_offset + x, y_offset + y)
  end
end
end