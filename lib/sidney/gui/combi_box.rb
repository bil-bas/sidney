

class CombiBox
  FONT_SIZE = 14
  PADDING = 2

  attr_accessor :index

  def index; @options.keys.index(@value); end
  def value; @value; end
  def text; @options[@value]; end

  def value=(value)
    if @options[@value]
      @value = value
      @on_change.call(self, @value) if @on_change
    end
  end

  def index=(index)
    if (0...@options.size).include? index
      self.value = @options.keys[index]
    end
  end

  def rect; @rect.dup; end

  # Options are { value => text } pairs
  protected
  def initialize(x, y, width, height, options, initial_value)
    @options, @value = options, initial_value

    @font = Gosu::Font.new($window, nil, FONT_SIZE)

    @border_color = 0xffffffff
    @background_color = 0xff666666
    @drop_down_background_color = 0xff333333
    @hover_background_color = 0xff999999

    @z = ZOrder::GUI
    @popup_z = @z + 0.01
    
    @open = true
    @hover_index = 0

    @rect = Rect.new(x, y, width, height)
    @popup_rect = Rect.new(x, y + height, width, height * @options.size)

    @on_change = nil
  end

  public
  def update
    nil
  end

  public
  def draw
    $window.draw_box(@rect.x, @rect.y, @rect.width, @rect.height, @z, @border_color, @background_color)
    @font.draw(text, @rect.x + PADDING, @rect.y + (@rect.height - FONT_SIZE) / 2, @z)

    # Draw the drop-down menu beneath.
    if @open
      $window.draw_box(@popup_rect.x, @popup_rect.y, @popup_rect.width, @popup_rect.height, @popup_z, @border_color, @drop_down_background_color)

      @options.each_with_index do |option, i|
        y = @popup_rect.y + (@rect.height * i)
        
        if i == @hover_index
          $window.draw_box(@popup_rect.x, y + 1, @popup_rect.width - 1, @rect.height - 1, @popup_z, nil, @hover_background_color)
        end

        @font.draw(option[1], @popup_rect.x + PADDING, y + ((@rect.height - FONT_SIZE) / 2), @popup_z)
      end
    end

    nil
  end

  public
  def hit?(x, y)
    hit = if @open
      @rect.collide_point?(x, y) or @popup_rect.collide_point?(x, y)
    else
      @rect.collide_point?(x, y)
    end
    
    @open = hit

    # Ensure that the index we are hovering over is highlighted.
    if @popup_rect.collide_point?(x, y)
      @hover_index = ((y - @popup_rect.y) / @rect.height).floor
    else
      @hover_index = index
    end

    hit
  end

  public
  def click(x, y)
    hit = hit?(x, y)
    if hit
      if @open
        new_value = @options.keys[@hover_index]
        if @popup_rect.collide_point?(x, y) and new_value != @value
          self.value = new_value
        end

        @open = false
      end
    end

    hit
  end

  def on_change(method = nil, &block)
    @on_change = method ? method : block
  end
end