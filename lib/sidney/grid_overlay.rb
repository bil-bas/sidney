class GridOverlay
  PIXEL_COLOR = Color.new(0x66888888) # ARGB
  BLOCK_COLOR = Color.new(0xff888888)
  EDGE_COLOR = Color.new(0xffffffff)

  Z = ZOrder::GRID_OVERLAY

  attr_reader :width, :height, :cell_width
  def cell_width=(value)
    @cell_width = value.to_i
  end
  
  public
  def visible?; @visible; end
  def show!; @visible = true; end
  def hide!; @visible = false; end

  protected
  def initialize(width, height, cell_width)
    @width, @height, @cell_width = width.to_i, height.to_i, cell_width.to_i

    @visible = true
  end

  public
  def draw(offset_x, offset_y)
    offset_x, offset_y = offset_x.modulo(cell_width) - cell_width, offset_y.modulo(cell_width) - cell_width

    if @visible
      # Single-pixel grid
      if @width < cell_width * 4
        (offset_y..@height).step(@cell_width / 16) do |y|
          $window.draw_line(offset_x, y, PIXEL_COLOR, @width, y, PIXEL_COLOR, Z)
        end

        (offset_x..@width).step(@cell_width / 16) do |x|
          $window.draw_line(x, offset_y, PIXEL_COLOR, x, @height, PIXEL_COLOR, Z)
        end

        block_color = BLOCK_COLOR
      else
        block_color = PIXEL_COLOR
      end

      # 16-pixel grid
      (offset_y..@height).step(@cell_width) do |y|
        $window.draw_line(offset_x, y, block_color, @width, y, block_color, Z)
      end

      (offset_x..@width).step(@cell_width) do |x|
        $window.draw_line(x, offset_y, block_color, x, @height, block_color, Z)
      end

      # Edge
      $window.draw_box(0, 0, @width, @height, Z, EDGE_COLOR)
    end

    nil
  end
end
