class EditScene < GameState
  def initialize
    super

    @grid = Grid.new(($window.height / 240).floor)

    self.input = {
      :left_mouse_button => :left_mouse_button,
      :released_left_mouse_button => :released_left_mouse_button,
      :holding_left_mouse_button => :holding_left_mouse_button,
      :right_mouse_button => :right_mouse_button,
      :released_right_mouse_button => :released_right_mouse_button,
      :holding_right_mouse_button => :holding_right_mouse_button,
      :g => lambda { @grid.toggle_overlay },
      :wheel_up => lambda { @grid.scale *= 2 },
      :wheel_down => lambda { @grid.scale /= 2 },
    }

    nil
  end

  def left_mouse_button


    nil
  end


  def released_left_mouse_button
    #p "release"

    nil
  end

  def holding_left_mouse_button
    x, y = @grid.screen_to_grid($window.cursor.x, $window.cursor.y)
    if object = @grid.hit_object(x, y)
      object.set_screen_pixel(x, y, :red)
    end

    nil
  end

  def right_mouse_button
    nil
  end

  def released_right_mouse_button
    nil
  end

  def holding_right_mouse_button
    x, y = @grid.screen_to_grid($window.cursor.x, $window.cursor.y)
    if object = @grid.hit_object(x, y)
      object.set_screen_pixel(x, y, :blue)
    end

    nil
  end

  def update
    @grid.update

    super
  end

  def draw
    @grid.draw

    super
  end
=begin
  # Called Each time when we enter the game state, use this to reset the gamestate to a "virgin state"
  def setup
  end

  # Called when we leave the game state
  def finalize
  end
=end
end