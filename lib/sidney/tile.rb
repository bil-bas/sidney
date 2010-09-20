require 'chingu'

module Sidney
class Tile < GameObject
  def initialize(options = {})
    super({center: 0, zorder: ZOrder::BACKGROUND}.merge!(options))
  end

  def draw_to_buffer(buffer)
    buffer.splice(image, x, y)
  end
end
end