require 'combi_box'

class EditScene < GameState
  def initialize
    super

    @grid = Grid.new(($window.height / 240).floor)

    zooms = {0.5 => "50%", 1 => "100%", 2 => "200%", 4 => "400%", 8 => "800%"}
    @zoom_box = CombiBox.new(@grid.margin_x + @grid.screen_width + 10, 0, 12 * @grid.scale, 8 * @grid.scale, zooms, 1)
    @zoom_box.on_change do |widget, value|
      @grid.scale = value * @grid.base_scale
    end

    self.input = {
      :left_mouse_button => :left_mouse_button,
      :released_left_mouse_button => :released_left_mouse_button,
      :holding_left_mouse_button => :holding_left_mouse_button,
      :right_mouse_button => :right_mouse_button,
      :released_right_mouse_button => :released_right_mouse_button,
      :holding_right_mouse_button => :holding_right_mouse_button,
      :g => lambda { @grid.toggle_overlay },
      :wheel_up => lambda { @zoom_box.index += 1 },
      :wheel_down => lambda { @zoom_box.index -= 1 },
      :holding_left => lambda { @grid.left },
      :holding_right => lambda { @grid.right },
      :holding_up => lambda { @grid.up },
      :holding_down => lambda { @grid.down },
    }

    nil
  end

  def left_mouse_button
    @zoom_box.click($window.cursor.x, $window.cursor.y)

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
    @zoom_box.hit?($window.cursor.x, $window.cursor.y)

    super
  end

  def draw
    @grid.draw
    @zoom_box.draw
    
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