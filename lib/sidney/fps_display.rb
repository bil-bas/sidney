module Sidney
class FPSDisplay
  TEXT = 'FPS: '
  COLOR = Color.new(0x88ffffff)
  FONT_SIZE = 16

  attr_reader :x, :y, :width, :height

  public
  def visible?; @visible; end
  def show!; @visible = true; end
  def hide!; @visible = false; end
  
  protected
  def initialize(x, y)
    @x, @y = x, y
    @font = Font.new($window, nil, FONT_SIZE)

    @visible = true

    nil
  end

  public
  def draw
    if @visible
      @font.draw("#{TEXT}#{"%2d" % [$window.fps]}", @x, @y, ZOrder::FPS, 1, 1, COLOR)
    end

    nil
  end

  public
  def toggle
    visible? ? hide! : show!

    nil
  end
end
end
