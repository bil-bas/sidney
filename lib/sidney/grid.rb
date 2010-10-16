require_relative 'grid_overlay'

module Sidney
class Grid
  CELLS_WIDE, CELLS_HIGH = 20, 15
  CELL_WIDTH = CELL_HEIGHT = 16
  WIDTH = CELL_WIDTH * CELLS_WIDE
  HEIGHT = CELL_WIDTH * CELLS_HIGH
  SCALE_RANGE = (0.5)..8 # From double zoom to 1/8 zoom.
  MARGIN = 4

  public
  attr_reader :scale, :base_scale, :rect

  attr_reader :offset_x, :offset_y

  attr_writer :offset_x, :offset_y

  def zoom; 1.0 / @scale; end
  def scroll_step; zoom * 4; end

  # Move view-port right one step (scroll background left).
  def right; if @offset_x > 0 then @offset_x -= scroll_step; end; end
  def left; if @offset_x < WIDTH then @offset_x += scroll_step; end; end
  def down; if @offset_y > 0 then @offset_y -= scroll_step; end; end
  def up; if @offset_y < HEIGHT then @offset_y += scroll_step; end; end

  public
  def scale=(n)
    if @scale_range.include? n
      @scale = n.to_f
      @overlay.cell_width = CELL_WIDTH * @scale

      @scale      
    else
      nil
    end
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