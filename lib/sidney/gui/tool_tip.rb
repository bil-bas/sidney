# encoding: utf-8

require_relative 'label'

module Sidney
module Gui
class ToolTip < Label
  DEFAULT_BACKGROUND_COLOR = Color.rgb(25, 25, 25)
  DEFAULT_BORDER_COLOR = Color.rgb(255, 255, 255)

  def x=(value); super(value); recalc; value; end
  def y=(value); super(value); recalc; value; end

  protected
  def initialize(parent, options = {}, &block)
    options = {
      background_color: DEFAULT_BACKGROUND_COLOR.dup,
      border_color: DEFAULT_BORDER_COLOR.dup
    }.merge! options

    super(parent, options)
  end

  protected
  def layout
    width, height = font.text_width(@text) + padding_x * 2, font_size + padding_y * 2
    # Ensure the tip can't go other the edge of the screen.
    rect.x = [x, $window.width - width - padding_x].min
    rect.y = [y, $window.height - height - padding_y].min
    rect.width = width
    rect.height = height
  end
end
end
end