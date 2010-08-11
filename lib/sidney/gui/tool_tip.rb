require 'gui/gui_element'

module Sidney
class ToolTip < GuiElement
  def initialize(x, y)
    super(x, y, 0, 0, ZOrder::GUI)

    @text = ''
  end

  def text=(value)
    @text = value
  end

  def draw
    $window.draw_box(x, y, @font.text_width(@text), 0xff000000, nil)

    font.draw(@text, x + PADDING_X, y + PADDING_Y, z, 0xffffffff)
  end

end
end