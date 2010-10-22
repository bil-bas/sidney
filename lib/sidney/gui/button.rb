require_relative 'element'

module Sidney
module Gui
class Button < Element
  BACKGROUND_COLOR = Color.rgb(100, 100, 100)
  BORDER_COLOR = Color.rgb(150, 150, 150)
  TEXT_COLOR = Color.rgb(255, 255, 255)

  protected
  def initialize(parent, text, options = {}, &block)
    options = {
    }.merge! options

    @text = text
    
    super(parent, options)

    rect.height = [font_size + padding_y * 2, height].max
    rect.width = [font.text_width(@text) + padding_x * 2, width].max

    post_init &block
  end

  public
  def draw
    $window.draw_box(x, y, width, height, z, BORDER_COLOR, BACKGROUND_COLOR)

    font.draw(@text, x + padding_x, y + padding_y, z, 1, 1, TEXT_COLOR)

    nil
  end

  public
  def click
    publish(:click)

    nil
  end
end
end
end