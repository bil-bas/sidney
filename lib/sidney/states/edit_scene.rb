require 'gui/combi_box'

class EditScene < GameState
  def initialize
    super

    @grid = Grid.new(($window.height / 240).floor)

    zooms = {0.5 => "50%", 1 => "100%", 2 => "200%", 4 => "400%", 8 => "800%"}
    @zoom_box = CombiBox.new(@grid.rect.right + 12, 12, 20 * @grid.scale, 8 * @grid.scale, zooms, 1)
    @zoom_box.on_change do |widget, value|
      @grid.scale = value * @grid.base_scale
    end

    @font = Font.new($window, nil, 14)

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

    @context_menu = nil
  end

  def left_mouse_button

    nil
  end


  def released_left_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    @zoom_box.click(x, y)
    if @context_menu and @context_menu.hit?(x, y)
      @context_menu.click(x, y)
      @context_menu = nil
    end

    nil
  end

  def holding_left_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      x, y = @grid.screen_to_grid(x, y)
      if object = @grid.hit_object(x, y)
        object.set_screen_pixel(x, y, :red)
      end
    end

    nil
  end

  def right_mouse_button
    nil
  end

  def released_right_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      x, y = @grid.screen_to_grid(x, y)
      if object = @grid.hit_object(x, y)
        items = { :edit => "Edit", :copy => "Copy\t(Ctrl+C)", :paste => "Paste\t(Ctrl+V)", :delete => "Delete\t(Ctrl+X)"}
        @context_menu = MenuPane.new(items, $window.mouse_x, $window.mouse_y, ZOrder::DIALOG)
        @context_menu.on_select do |widget, value|
          case value
            when :delete
              @grid.objects.delete(object)

            else
              p "#{value} #{object}"

          end
        end
      end
    end
    
    nil
  end

  def holding_right_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      x, y = @grid.screen_to_grid(x, y)
      if object = @grid.hit_object(x, y)
        object.set_screen_pixel(x, y, :blue)
      end
    end

    nil
  end

  def update
    @grid.update
    x, y = $window.cursor.x, $window.cursor.y
    @zoom_box.hit?(x, y)
    @context_menu.hit?(x, y) if @context_menu

    super
  end

  def draw
    @grid.draw
    @zoom_box.draw
    @context_menu.draw if @context_menu

    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      x, y = @grid.screen_to_grid(x, y)
      x, y = x.to_i, y.to_i
    else
      x, y = 'x', 'y'
    end
    @font.draw("(#{x}, #{y})", 0, 650, ZOrder::GUI)
    
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