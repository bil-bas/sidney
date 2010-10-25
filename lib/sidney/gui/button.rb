# encoding: utf-8

require_relative 'label'

module Sidney
module Gui
class Button < Label
  public
  def clicked_left_mouse_button(sender, x, y)
    # TODO: Play click sound?
    nil
  end
end
end
end