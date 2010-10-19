require_relative 'gui_element'

module Sidney
class ToolTip < GuiElement
  BACKGROUND_COLOR = Color.rgb(25, 25, 25)
  BORDER_COLOR = Color.rgb(255, 255, 255)
  TEXT_COLOR = Color.rgb(255, 255, 255)

  protected
  def initialize(text)
    @text = text

    x = $window.cursor.x
    y = $window.cursor.y + $window.cursor.height # Place the tip beneath the cursor.
    width, height = font.text_width(@text) + PADDING_X * 2, FONT_SIZE + PADDING_Y * 2
    # Ensure the tip can't go other the edge of the screen.
    x = [x, $window.width - width - PADDING_X].min
    y = [y, $window.height - height - PADDING_Y].min

    super(x, y, width, height, ZOrder::TOOL_TIP)
  end

  public
  def draw
    $window.draw_box(x, y, width, height, z, BORDER_COLOR, BACKGROUND_COLOR)

    font.draw(@text, x + PADDING_X, y + PADDING_Y, z, 1, 1, TEXT_COLOR)

    nil
  end

end
end