require 'chingu'
require 'gosu_ext/image'

module Sidney
class Sprite < GameObject
  attr_writer :selected, :dragging

  def dragging?; @dragging; end
  def selected?; @selected; end

  def initialize(options = {})
    super({:center_y => 1}.merge(options))
  end

  def setup
    @dragging = false
    @z = 0
    @selected = false

    nil
  end

  def update(z)
    self.zorder = if @dragging
      ZOrder::DRAGGING + self.y / 10000.0
    else
      (self.y * 256) + z
    end

    nil
  end

  def draw
    if @selected
      image.redraw_outline unless image.outline
      color = 0x00ffff00 + ((Math.sin(Time.now.to_f * 4) * 50 + 180).to_i.abs * 256 * 256 * 256)
      image.outline.draw((self.x - self.width * center_x) - 1, (self.y - self.height * center_y) - 1, zorder, 1, 1, color)
    end

    image.draw((self.x - self.width * center_x), (self.y - self.height * center_y), zorder)
  end

  def hit?(x, y)
    pixel = image.get_pixel(x - self.x + (center_x * image.width),
             y - self.y + (center_y * image.height))

    pixel and pixel[3] != 0
  end

  # Set a pixel within our image using image co-ordinates.
  public
  def []=(x, y, color)
    image.set_pixel(x, y, :color => color)
    image.redraw_outline
  end
  
  # Set the pixel at screen location.
  public
  def set_screen_pixel(x, y, color)
    self[x - self.x + (center_x * image.width), y - self.y + (center_y * image.height)] = color
  end

  public
  def rect
    Rect.new(x - center_x * width, y - center_y * height, width, height)
  end
end
end
