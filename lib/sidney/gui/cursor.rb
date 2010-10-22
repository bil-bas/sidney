# encoding: utf-8

module Sidney
module Gui
class Cursor < GameObject
  protected
  def initialize(options = {})
    super({image: Image["mouse.png"], center: 0, zorder: ZOrder::CURSOR}.merge(options))

    nil
  end

  # Is the mouse pointer position inside the game window pane?
  public
  def inside_window?
    x >= 0 and y >= 0 and x < $window.width and y < $window.height
  end

  public
  def update
    self.x, self.y = $window.mouse_x, $window.mouse_y

    super

    nil
  end

  public
  def draw
    # Prevent system and game mouse from being shown at the same time.
    super if inside_window?
  end
end
end
end