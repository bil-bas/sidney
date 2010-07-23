class Sprite < GameObject
  trait :retrofy

  def dragging?; @dragging; end

  def initialize(options = {})
    super({:center_y => 1}.merge(options))
    #image.force_refresh_cache
  end

  def setup
    @dragging = false
    @z = 0
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
    image.draw((self.x - self.width * center_x) + x, (self.y - self.height * center_y) + y, zorder)
  end

  def hit?(x, y)
    pixel = image.get_pixel(x - self.x + (center_x * image.width),
             y - self.y + (center_y * image.height))

    pixel and pixel[3] != 0
  end

  # Set a pixel within our image using image co-ordinates.
  def set_pixel(x, y, color)
    image.pixel(x, y, :color => color)
  end

  # Set the pixel at screen location.
  def set_screen_pixel(x, y, color)
    set_pixel(x - self.x + (center_x * image.width),
               y - self.y + (center_y * image.height), color)

  end

  def show_hide
    visible? ? hide! : show!

    nil
  end
end
