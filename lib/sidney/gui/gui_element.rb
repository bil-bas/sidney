class GuiElement
  FONT_SIZE = 14
  PADDING_X, PADDING_Y = 8, 4
  
  attr_reader :rect, :z

  def initialize(x, y, width, height, z)
    @rect = Rect.new(x, y, width, height)
    @z = z
  end

  def hit?(x, y)
    @rect.collide_point?(x, y)
  end
end