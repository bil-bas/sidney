class ShowMenu < GameState
  protected
  def initialize(menu)
    @menu = menu

    self.input = {
      [:released_left_mouse_button, :released_right_mouse_button] => :released_button,
      :escape => lambda { game_state_manager.pop },
    }
  end

  public
  def released_button
    game_state_manager.pop # Close the menu.

    x, y = $window.cursor.x, $window.cursor.y
    @menu.click(x, y) if @menu.hit?(x, y)

    nil
  end

  public
  def draw
    game_state_manager.previous.draw
    @menu.draw
  end

  public
  def update
    @menu.hit?($window.cursor.x, $window.cursor.y)

    nil
  end
end