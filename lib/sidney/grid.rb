require_relative 'grid_overlay'

module Sidney
class Grid
  CELLS_WIDE, CELLS_HIGH = 20, 15
  CELL_WIDTH = CELL_HEIGHT = 16
  WIDTH = CELL_WIDTH * CELLS_WIDE
  HEIGHT = CELL_WIDTH * CELLS_HIGH
  SCALE_RANGE = (0.5)..8 # From double zoom to 1/8 zoom.
  MARGIN = 4
  VIEW_EDGE = 0.5 # Amount of screen to see over the edge.

  public
  attr_reader :scale, :base_scale, :rect

  attr_reader :offset_x, :offset_y

  attr_writer :offset_x, :offset_y

  def zoom; 1.0 / @scale; end
  def scroll_step; zoom * 4; end

  # Move view-port right one step (scroll background left).
  def right; @offset_x -= scroll_step; limit_offset; end
  def left; @offset_x += scroll_step; limit_offset; end
  def down; @offset_y -= scroll_step; limit_offset; end
  def up; @offset_y += scroll_step; limit_offset; end

  public
  def scale=(value)
    if @scale_range.include? value
      # If the mouse is inside the grid, then zoom on that. Otherwise, zoom around the centre of the screen.
      mouse_x, mouse_y = $window.mouse_x, $window.mouse_y
      screen_focus_x, screen_focus_y = if hit?(mouse_x, mouse_y)
        [mouse_x, mouse_y]
      else
        [rect.center_x, rect.center_y]
      end

      old_grid_focus_x, old_grid_focus_y = screen_to_grid(screen_focus_x, screen_focus_y)

      # Zoom in/out.
      @scale = value.to_f
      @overlay.cell_width = CELL_WIDTH * @scale

      # Scroll the screen until it centres properly.
      new_grid_focus_x, new_grid_focus_y = screen_to_grid(screen_focus_x, screen_focus_y)
      @offset_x += new_grid_focus_x - old_grid_focus_x
      @offset_y += new_grid_focus_y - old_grid_focus_y

      limit_offset

      @scale      
    else
      nil
    end
  end

  # Prevent users from scrolling off the edge of the viewable area.
  protected
  def limit_offset
    @offset_x = [[-WIDTH * ((1 + VIEW_EDGE) - (zoom * @base_scale)), @offset_x].max, WIDTH * VIEW_EDGE].min
    @offset_y = [[-HEIGHT * ((1 + VIEW_EDGE) - (zoom * @base_scale)), @offset_y].max, HEIGHT * VIEW_EDGE].min

    nil
  end

  public
  def hit?(x, y)
    @rect.collide_point?(x, y)
  end

  protected
  def initialize(scale)
    @base_scale = @scale = scale.to_f

    @scale_range = (@base_scale * SCALE_RANGE.min)..(@base_scale * SCALE_RANGE.max)

    x, y = (@base_scale * MARGIN).to_i, (@base_scale * MARGIN).to_i
    width, height = (WIDTH * @base_scale).to_i, (HEIGHT * @base_scale).to_i
    @rect = Rect.new(x, y, width, height)
    @overlay = GridOverlay.new(@rect.width, @rect.height, CELL_WIDTH * @scale)

    @offset_x, @offset_y = WIDTH / 2, HEIGHT / 2
  end

  public
  def draw_with_respect_to
    $window.translate(@rect.x, @rect.y) do
      $window.clip_to(-1, 0, @rect.width + 1, @rect.height + 1) do
        $window.scale(scale) do
          $window.translate(@offset_x, @offset_y) do
            yield
          end
        end
      end
    end
  end

  public
  def draw
    $window.translate(@rect.x, @rect.y) do
      $window.clip_to(-1, 0, @rect.width + 1, @rect.height + 1) do
        @overlay.draw(@offset_x * scale, @offset_y * scale)
      end
    end

    nil
  end

  # Show/hide the grid overlay.
  public
  def toggle_overlay
    @overlay.visible? ? @overlay.hide! : @overlay.show!

    nil
  end

  # Convert screen coordinates to pixellised coordinates.
  public
  def screen_to_grid(x, y)
    [((x - @rect.x) / @scale) - @offset_x, ((y - @rect.y) / @scale) - @offset_y]
  end

  # Convert pixellised coordinates into screen coordinates.
  public
  def grid_to_screen(x, y)
    [((x + @offset_x) * @scale) + @rect.x, ((y + @offset_y) * @scale) + @rect.y]
  end
end
end