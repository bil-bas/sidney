require_relative 'element'

module Sidney
module Gui
class ToolTip < Element
  BACKGROUND_COLOR = Color.rgb(25, 25, 25)
  BORDER_COLOR = Color.rgb(255, 255, 255)
  TEXT_COLOR = Color.rgb(255, 255, 255)

  protected
  def initialize(text, &block)
    @text = text

    super(nil, z: ZOrder::TOOL_TIP)

    x = $window.cursor.x
    y = $window.cursor.y + $window.cursor.height # Place the tip beneath the cursor.

    width, height = font.text_width(@text) + padding_x * 2, font_size + padding_y * 2
    # Ensure the tip can't go other the edge of the screen.
    rect.x = [x, $window.width - width - padding_x].min
    rect.y = [y, $window.height - height - padding_y].min
    rect.width = width
    rect.height = height

    post_init &block
  end

  public
  def draw
    $window.draw_box(x, y, width, height, z, BORDER_COLOR, BACKGROUND_COLOR)

    font.draw(@text, x + padding_x, y + padding_y, z, 1, 1, TEXT_COLOR)

    nil
  end

end
end
end