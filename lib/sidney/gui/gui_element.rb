require_relative '../gosu_ext'

module Sidney
class GuiElement
  FONT_SIZE = 15
  FONT_NAME = File.join(ROOT_PATH, 'media', 'fonts', 'SFPixelate.ttf')
  PADDING_X, PADDING_Y = 10, 5
  
  attr_reader :rect, :z, :tip

  def font; @@font; end
  def x; rect.x; end
  def x=(value); rect.x = value; end
  def y; rect.y; end
  def y=(value); rect.y = value; end
  def width; rect.width; end
  def height; rect.height; end

  def initialize(x, y, width, height, z, options = {})
    options = {
      tip: ''
    }.merge! options

    @rect = Rect.new(x, y, width, height)

    @z = z

    @tip = options[:tip]

    @@font ||= Font.new($window, FONT_NAME, FONT_SIZE)
  end

  # Check if a point (screen coordinates) is over the element.
  public
  def hit?(x, y)
    @rect.collide_point?(x, y)
  end

  # Hover the mouse over the element.
  public
  def hover(x, y)
    nil
  end

  # Mouse moves over the element.
  def enter
    nil
  end

  # Mouse leaves the element.
  def leave
    nil
  end

  # Clicked the mouse button (usually only the left one) on the element.
  def click(x, y) 
    nil
  end

  # Redraw the element.
  def draw
    nil
  end

  # Update the element.
  def update
    nil
  end
end
end