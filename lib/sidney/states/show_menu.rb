require_relative '../states/gui_state'

require_relative '../log'

module Sidney

class ShowMenu < GuiState
  include Log
  protected
  def initialize(menu)
    @menu = menu
    super()

    add_element @menu
  end

  public
  def setup
    add_inputs(
      [:left_mouse_button, :right_mouse_button] => :mouse_button_down,
      [:released_left_mouse_button, :released_right_mouse_button] => :mouse_button_up,
      :escape => lambda { game_state_manager.pop }
    )

    log.info { "Opened menu" }

    nil
  end

  public
  def finalize
    log.info { "Closed menu" }
    nil
  end

  # Close the menu if the user clicks down outside the menu.
  public
  def mouse_button_down
    game_state_manager.pop unless @menu.hit?(cursor.x, cursor.y)
    
    nil
  end

  public
  def cursor
    $window.cursor
  end

  # Close the menu and register a click if the menu was clicked.
  public
  def mouse_button_up
    game_state_manager.pop # Close the menu.

    x, y = cursor.x, cursor.y
    @menu.click(x, y) if @menu.hit?(x, y)

    nil
  end

  public
  def update
    $window.cursor.update
    super
  end

  public
  def draw
    game_state_manager.previous.draw

    super

    $window.cursor.draw
    nil
  end
end
end