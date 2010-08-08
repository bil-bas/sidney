require 'gosu/image'

class Sprite < GameObject
  trait :retrofy

  attr_writer :selected, :dragging

  def dragging?; @dragging; end
  def selected?; @selected; end

  def initialize(options = {})
    super({:center_y => 1}.merge(options))
    #image.force_refresh_cache
  end

  def setup
    @dragging = false
    @z = 0
    @selected = false

    nil
  end

  def update(z)
    self.zorder = if @dragging
      ZOrder::DRAGGING
    else
      (self.y * 256) + z
    end

    nil
  end

  def draw(x, y)
    if @selected
      image.redraw_outline unless image.outline
      color = 0xffffff00
      image.outline.draw((self.x - self.width * center_x) + x - 1, (self.y - self.height * center_y) + y - 1, zorder, 1, 1, color)
    end

    image.draw((self.x - self.width * center_x) + x, (self.y - self.height * center_y) + y, zorder)
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
