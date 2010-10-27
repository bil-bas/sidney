# encoding: utf-8

module Sidney
class GridOverlay < Element
  PIXEL_COLOR = Color.new(0x66888888) # ARGB
  BLOCK_COLOR = Color.new(0xff888888)

  attr_reader :cell_width
  def cell_width=(value)
    @cell_width = value.to_i
  end
  
  public
  def hit?(x, y); false; end
  def visible?; @visible; end
  def show!; @visible = true; end
  def hide!; @visible = false; end

  protected
  def initialize(parent, cell_width, options = {})
    @cell_width = cell_width

    @visible = true

    super parent, options
  end

  public
  def draw(offset_x, offset_y)
    if @visible
      $window.clip_to(0, 0, width, height) do
        draw_lines(offset_x, offset_y)
      end
    end
  end

  protected
  def draw_lines(offset_x, offset_y)
    offset_x, offset_y = offset_x.modulo(cell_width) - cell_width, offset_y.modulo(cell_width) - cell_width

    # Single-pixel grid
    if width < cell_width * 8
      (offset_y..height).step(@cell_width / 16) do |y|
        draw_rect(offset_x, y, width - offset_x, 1, z, PIXEL_COLOR)
      end

      (offset_x..width).step(@cell_width / 16) do |x|
        draw_rect(x, offset_y, 1, height - offset_y, z, PIXEL_COLOR)
      end

      block_color = BLOCK_COLOR
    else
      block_color = PIXEL_COLOR
    end

    # 16-pixel grid
    (offset_y..height).step(cell_width) do |y|
      draw_rect(offset_x, y, width - offset_x, 1, z, block_color)
    end

    (offset_x..width).step(@cell_width) do |x|
      draw_rect(x, offset_y, 1, height - offset_y, z, block_color)
    end

    nil
  end
end
end
