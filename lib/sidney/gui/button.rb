# encoding: utf-8

require_relative 'label'

module Sidney
module Gui
class Button < Label
  DEFAULT_BACKGROUND_COLOR = Color.rgb(100, 100, 100)
  DEFAULT_BORDER_COLOR = Color.rgb(150, 150, 150)
  DEFAULT_COLOR = Color.rgb(255, 255, 255)

  def initialize(parent, options = {}, &block)
    options = {
      color: DEFAULT_COLOR.dup,
      background_color: DEFAULT_BACKGROUND_COLOR.dup,
      border_color: DEFAULT_BORDER_COLOR.dup
    }.merge! options



    super(parent, options)
  end

  public
  def clicked_left_mouse_button(sender, x, y)
    # TODO: Play click sound?
    nil
  end

  public
  def enter(sender)
    @background_color = Color.rgb(150, 150, 150)

    nil
  end

  public
  def leave(sender)
    @background_color = Color.rgb(100, 100, 100)

    nil
  end
end
end
end