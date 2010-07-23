require 'grid_overlay'
require 'sprite'
require 'tile'

class Grid
  CELLS_WIDE, CELLS_HIGH = 13, 13
  CELL_WIDTH = CELL_HEIGHT = 16
  WIDTH = CELL_WIDTH * CELLS_WIDE
  HEIGHT = CELL_WIDTH * CELLS_HIGH
  SCALE_RANGE = (0.5)..8 # From double zoom to 1/8 zoom.
  MARGIN = 4

  attr_reader :scale, :base_scale, :rect

  attr_reader :offset_x, :offset_y

  attr_writer :offset_x, :offset_y

  def zoom; 1.0 / @scale; end
  def scroll_step; zoom * 4; end

  # Move view-port right one step (scroll background left).
  def right; if @offset_x > 0 then @offset_x -= scroll_step; end; end
  def left; if @offset_x < WIDTH - (@rect.width / @scale) / CELL_WIDTH then @offset_x += scroll_step; end; end
  def down; if @offset_y > 0 then @offset_y -= scroll_step; end; end
  def up; if @offset_x < HEIGHT then @offset_y += scroll_step; end; end

  public
  def scale=(n)
    if @scale_range.include? n
      @scale = n
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

  def initialize(scale)
    @base_scale = @scale = scale.to_f
    
    x, y = (@base_scale * MARGIN).to_i, (@base_scale * MARGIN).to_i

    @scale_range = (@base_scale * SCALE_RANGE.min)..(@base_scale * SCALE_RANGE.max)

    @objects = Array.new
    @tiles = Array.new
    1.times do
    CELLS_WIDE.times do |x|
      CELLS_HIGH.times do |y|
        @tiles.push Tile.new(:image => "tile.png", :x => x  * CELL_WIDTH, :y => y * CELL_HEIGHT)
        @objects.push Sprite.new(:image => Image["object.png"].dup, :x => (x + 0.5) * CELL_WIDTH, :y => (y + 1) * CELL_HEIGHT) if rand(100) < 40
      end
    end
    end

    @objects[0].instance_variable_set(:@dragging, true)

    width, height = (WIDTH * @base_scale).to_i, (HEIGHT * @base_scale).to_i
    @rect = Rect.new(x, y, width, height)
    @overlay = GridOverlay.new(@rect.width, @rect.height, CELL_WIDTH * @scale)

    @offset_x, @offset_y = 30, 0   
  end

  def hit_object(x, y)
    if hit?(x, y)
      @objects.reverse.find do |object|
        object.hit?(x, y)
      end
    end
  end
  
  def update
    @objects.each_with_index do |object, i|
      object.update(i)
    end

    nil
  end

  def draw
    $window.translate(@rect.x, @rect.y) do
      
      $window.clip_to(@rect.x - 1, @rect.y, @rect.width + 1,
                      @rect.height + 1) do

        $window.scale(@scale) do
          @objects.each { |o| o.draw(@offset_x, @offset_y) }
          @tiles.each { |o| o.draw(@offset_x, @offset_y) }
        end
        
        @overlay.draw(@offset_x * @scale, @offset_y * @scale)
      end
    end

    nil
  end

  # Show/hide the grid overlay.
  def toggle_overlay
    @overlay.visible? ? @overlay.hide! : @overlay.show!

    nil
  end

  # Convert screen coordinates to pixellised coordinates.
  def screen_to_grid(x, y)
    [((x - @rect.x) / @scale) - @offset_x, ((y - @rect.y) / @scale) - @offset_y]
  end

  # Convert pixellised coordinates into screen coordinates.
  def grid_to_screen(x, y)
    [((x + @offset_x) * @scale) + @rect.x, ((y + @offset_y) * @scale) + @rect.y]
  end
end