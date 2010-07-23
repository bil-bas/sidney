require 'grid_overlay'
require 'sprite'
require 'tile'

class Grid
  CELLS_WIDE, CELLS_HIGH = 13, 13
  CELL_WIDTH = CELL_HEIGHT = 16
  WIDTH = CELL_WIDTH * CELLS_WIDE
  HEIGHT = CELL_WIDTH * CELLS_HIGH
  SCALE_RANGE = (0.5)..8 # From double zoom to 1/8 zoom.

  attr_reader :scale

  def set_offset(x, y)
    @offset_x, @offset_y = x, y
  end

  def offset
    [@offset_x, @offset_y]
  end

  def zoom; 1.0 / @scale; end

  def scale=(n)
    if @scale_range.include? n
      @scale = n
      @overlay.cell_width = CELL_WIDTH * @scale

      @scale      
    else
      nil
    end
  end

  def initialize(scale)
    @base_scale = @scale = scale.to_f
    @margin = (@base_scale * 4).to_i

    @scale_range = (@base_scale * SCALE_RANGE.min)..(@base_scale * SCALE_RANGE.max)

    @objects = Array.new
    @tiles = Array.new
    1.times do
    CELLS_WIDE.times do |x|
      CELLS_HIGH.times do |y|
        @tiles.push Tile.new(:image => "tile.png", :x => x  * CELL_WIDTH, :y => y * CELL_HEIGHT)
        @objects.push Sprite.new(:image => Image["object.png"], :x => (x + 0.5) * CELL_WIDTH, :y => (y + 1) * CELL_HEIGHT) if rand(100) < 40
      end
    end
    end

    @objects[0].instance_variable_set(:@dragging, true)

    @overlay = GridOverlay.new(WIDTH * @scale, HEIGHT * @scale, CELL_WIDTH * @scale)

    @offset_x, @offset_y = 30, 0
  end

  def hit_object(x, y)
    @objects.reverse.find do |object|
      object.hit?(x, y)
    end
  end
  
  def update
    @objects.each_with_index do |object, i|
      object.update(i)
    end

    nil
  end

  def draw
    $window.translate(@margin, @margin) do
      
      $window.clip_to(@margin - 1, @margin, @overlay.width + 1,
                      @overlay.height + 1) do

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
    [((x - @margin) / @scale) - @offset_x, ((y - @margin) / @scale) - @offset_y]
  end

  # Convert pixellised coordinates into screen coordinates.
  def grid_to_screen(x, y)
    [((x + @offset_x) * @scale) + @margin, ((y + @offset_y) * @scale) + @margin]
  end
end