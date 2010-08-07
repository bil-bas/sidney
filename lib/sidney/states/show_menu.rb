class ShowMenu < GameState
  protected
  def initialize(menu)
    @menu = menu

    self.input = {
      [:left_mouse_button, :right_mouse_button] => :mouse_button_down,
      [:released_left_mouse_button, :released_right_mouse_button] => :mouse_button_up,
      :escape => lambda { game_state_manager.pop },
    }
  end

  # Close the menu if the user clicks down outside the menu.
  public
  def mouse_button_down
    game_state_manager.pop unless @menu.hit?($window.cursor.x, $window.cursor.y)
    
    nil
  end

  # Close the menu and register a click if the menu was clicked.
  public
  def mouse_button_up
    game_state_manager.pop # Close the menu.

    x, y = $window.cursor.x, $window.cursor.y
    @menu.click(x, y) if @menu.hit?(x, y)

    nil
  end

  public
  def draw
    game_state_manager.previous.draw
    @menu.draw

    nil
  end

  public
  def update
    @menu.hit?($window.cursor.x, $window.cursor.y)

    nil
  end
end