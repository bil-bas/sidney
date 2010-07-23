require 'grid_overlay'
require 'sprite'
require 'tile'

class Grid
  CELLS_WIDE, CELLS_HIGH = 13, 13
  CELL_WIDTH = CELL_HEIGHT = 16
  WIDTH = CELL_WIDTH * CELLS_WIDE
  HEIGHT = CELL_WIDTH * CELLS_HIGH

  attr_reader :scale

  def scale=(n)
    if n > @max_scale or n < @min_scale
      nil
    else
      @scale = n
      @overlay.cell_width = CELL_WIDTH * @scale


      @scale
    end
  end

  def initialize(scale)
    @base_scale = @scale = scale.to_f
    @margin = (@base_scale * 4).to_i
    @max_scale = @base_scale * 8
    @min_scale = @base_scale * 0.5

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

    @overlay = GridOverlay.new(0, 0, WIDTH * @scale, HEIGHT * @scale, CELL_WIDTH * @scale)
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
      $window.scale(@scale) do
        $window.clip_to(@margin, @margin, @overlay.width,
                        @overlay.height) do

          @objects.each { |o| o.draw(0, 0) }
          @tiles.each { |o| o.draw(0, 0) }
        end
      end

      @overlay.draw
    end

    nil
  end

  def toggle_overlay
    @overlay.visible? ? @overlay.hide! : @overlay.show!

    nil
  end

  def screen_to_grid(x, y)
    [(x - @margin) / @scale, (y - @margin) / @scale]
  end

  def grid_to_screen(x, y)
    [(x * @scale) + @margin, (y * @scale) + @margin]
  end
end