class GridOverlay
  PIXEL_COLOR = Color.new(0x66888888) # ARGB
  BLOCK_COLOR = Color.new(0xff888888)
  EDGE_COLOR = Color.new(0xffffffff)

  attr_reader :x, :y, :width, :height, :cell_width
  def cell_width=(value)
    @cell_width = value.to_i
  end
  
  public
  def visible?; @visible; end
  def show!; @visible = true; end
  def hide!; @visible = false; end

  protected
  def initialize(x, y, width, height, cell_width)
    @x, @y, @width, @height, @cell_width = x.to_i, y.to_i, width.to_i, height.to_i, cell_width.to_i

    @visible = true
  end

  public
  def draw
    if @visible
      # Single-pixel grid
      if @width < cell_width * 4
        (@y..(@y + @height)).step(@cell_width / 16) do |y|
          $window.draw_line(@x, y, PIXEL_COLOR, @x + @width, y, PIXEL_COLOR, ZOrder::GRID)
        end

        (@x..(@x + @width)).step(@cell_width / 16) do |x|
          $window.draw_line(x, @y, PIXEL_COLOR, x, @y + @height, PIXEL_COLOR, ZOrder::GRID)
        end

        block_color = BLOCK_COLOR
      else
        block_color = PIXEL_COLOR
      end

      # 16-pixel grid
      (@y..(@y + @height)).step(@cell_width) do |y|
        $window.draw_line(@x, y, block_color, @x + @width, y, block_color, ZOrder::GRID)
      end

      (@x..(@x + @width)).step(@cell_width) do |x|
        $window.draw_line(x, @y, block_color, x, @y + @height, block_color, ZOrder::GRID)
      end

      # Edge
      $window.draw_line(@x, @y, EDGE_COLOR, @x, @y + @height, EDGE_COLOR, ZOrder::GRID) # left
      $window.draw_line(@x, @y, EDGE_COLOR, @x + @width, @y, EDGE_COLOR, ZOrder::GRID) # top
      $window.draw_line(@x, @y + @height, EDGE_COLOR, @x + @width, @y + @height, EDGE_COLOR, ZOrder::GRID) # bottom
      $window.draw_line(@x + @width, @y, EDGE_COLOR, @x + @width, @y + @height, EDGE_COLOR, ZOrder::GRID) # right
    end


    nil
  end
end
