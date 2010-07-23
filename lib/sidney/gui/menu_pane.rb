class MenuPane
  FONT_SIZE = 14
  PADDING_X, PADDING_Y = 8, 4

  attr_reader :items, :index

  def line_height; FONT_SIZE + PADDING_Y * 2; end
  
  public
  def initialize(items, x, y, z, options = {})
    @rect, @z = Rect.new(x, y, 0, 0), z

    @font = Gosu::Font.new($window, nil, FONT_SIZE)

    self.items = items   

    @background_color = 0xff333333
    @hover_background_color = 0xff999999
    @border_color = nil

    @on_select = nil # Handler.
    
    @index = nil # The index of the item hovered over.
  end

  public
  def items=(items)
    @items = items

    @rect.height = line_height * @items.size
    @items.each_pair do |value, text|
      @rect.width = [@rect.width, @font.text_width(text) + PADDING_X * 2].max
    end

    @items.size
  end

  public
  def update
    
  end

  public
  def draw
    $window.draw_box(@rect.x, @rect.y, @rect.width, @rect.height, @z, @border_color, @background_color)

    @items.each_with_index do |item, i|
      y = @rect.y + (line_height * i)

      if i == @index
        $window.draw_box(@rect.x, y, @rect.width, line_height, @z, nil, @hover_background_color)
      end

      @font.draw(item[1], @rect.x + PADDING_X, y + ((line_height - FONT_SIZE) / 2).floor, @z)
    end

    nil
  end

  public
  def hit?(x, y)
    hit =  @rect.collide_point?(x, y)

    if hit
      @index = ((y - @rect.y) / line_height).floor
    else
      @index = nil
    end

    @rect.collide_point?(x, y)
  end

  public
  def click(x, y)
    if hit?(x, y)
      @on_select.call(self, @items.keys[@index]) if @on_select
    end

    nil
  end

  public
  def on_select(method = nil, &block)
    @on_select = method ? method : block
  end
end