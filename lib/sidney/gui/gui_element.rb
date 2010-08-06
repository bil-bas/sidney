class GuiElement
  FONT_SIZE = 16
  FONT_NAME = 'Lucida Console'
  PADDING_X, PADDING_Y = 10, 5
  
  attr_reader :rect, :z

  def font
    @@font
  end

  def initialize(x, y, width, height, z)
    @rect = Rect.new(x, y, width, height)

    @z = z

    @@font ||= Font.new($window, FONT_NAME, FONT_SIZE)
  end

  def hit?(x, y)
    @rect.collide_point?(x, y)
  end

  def draw

  end

  def update
    
  end
end