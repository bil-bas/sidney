require_relative 'gui_element'

module Sidney
class Button < GuiElement
  BACKGROUND_COLOR = Color.rgb(100, 100, 100)
  BORDER_COLOR = Color.rgb(150, 150, 150)
  TEXT_COLOR = Color.rgb(255, 255, 255)
  DEFAULT_WIDTH = FONT_SIZE * 6

  protected
  def initialize(x, y, text, options = {})
    options = {
            width: DEFAULT_WIDTH
    }.merge! options

    @text = text

    width, height = font.text_width(@text) + PADDING_X * 2, FONT_SIZE + PADDING_Y * 2
    width = [width, options[:width]].max

    super(x, y, width, height, ZOrder::GUI, options)
  end

  public
  def draw
    $window.draw_box(x, y, width, height, z, BORDER_COLOR, BACKGROUND_COLOR)

    font.draw(@text, x + PADDING_X, y + PADDING_Y, z, 1, 1, TEXT_COLOR)

    nil
  end

  public
  def click
    publish(:click)

    nil
  end
end
end