require 'chingu'
require_relative 'gosu_ext/image'

module Sidney
class Sprite < GameObject
  attr_writer :selected, :dragging

  def dragging?; @dragging; end
  def selected?; @selected; end

  def initialize(options = {})
    super({center_x: 0, center_y: 1}.merge!(options))
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

  public
  def draw_to_buffer(buffer)
    buffer.splice(image, (x - width * center_x), (y - height * center_y), chroma_key: :alpha)
  end

  public
  def draw
    if @selected
      image.redraw_outline unless image.outline
      color = Color.from_texplay([1, 1, 0, ((Math.sin(Time.now.to_f * 4) * 50 + 180) / 256.0)])
      image.outline.draw((x - width * center_x) - 1, (y - height * center_y) - 1, zorder,
                    1, 1, color)
    end

    image.draw((x - width * center_x), (y - height * center_y), zorder)
  end

  def hit?(x, y)
    pixel = image.get_pixel(x - self.x + (center_x * image.width),
             y - self.y + (center_y * image.height))

    pixel and pixel[3] != 0
  end

  # Set a pixel within our image using image co-ordinates.
  public
  def []=(x, y, color)
    image.set_pixel(x, y, color: color)
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

  # Flip horizontally.
  public
  def mirror!
    @image = @image.mirror

    self
  end

  # Flip horizontally.
  public
  def flip!
    @image = @image.flip

    self
  end
end
end
