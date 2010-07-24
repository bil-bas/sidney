require 'gui/gui_element'
require 'gui/menu_pane'

class CombiBox < GuiElement
  attr_accessor :index

  def index; @menu.items.keys.index(@value) end
  def value; @value; end
  def text; @menu.items[@value]; end

  def value=(value)
    if @menu.items[value]
      if @value != value
        @value = value
        @on_change.call(self, @value) if @on_change
      end
    end
  end

  def index=(index)
    if index.between?(0, @menu.items.size)
      self.value = @menu.items.keys[index]
    end
  end

  def rect; @rect.dup; end

  # Options are { value => text } pairs
  protected
  def initialize(x, y, width, height, items, initial_value)
    super(x, y, width, height, ZOrder::GUI)

    @value = initial_value

    @border_color = 0xffffffff
    @background_color = 0xff666666
    
    @open = false
    @hover_index = 0

    @on_change = nil # Event handler.

    @menu = MenuPane.new(items, rect.left, rect.bottom + 1, z + 0.01)
    @menu.on_select do |widget, value|
      self.value = value
    end
  end

  public
  def update
    nil
  end

  public
  def draw
    $window.draw_box(rect.x, rect.y, rect.width, rect.height, z, @border_color, @background_color)
    font.draw(text, rect.x + PADDING_X, rect.y + ((rect.height - FONT_SIZE) / 2).floor, z)

    # Draw the drop-down menu beneath.
    @menu.draw if @open

    nil
  end

  public
  def hit?(x, y)
    hit = if @open
      super(x, y) or @menu.hit?(x, y)
    else
      super(x, y)
    end

    hit
  end

  public
  def menu_clicked(widget, value)
    self.value = value
  end

  public
  def click(x, y)
    hit = hit?(x, y)
    if hit
      if @open
        if @menu.hit?(x, y)
          @menu.click(x, y)          
        end
      end

      @open = (not @open)
    else

    end

    hit
  end

  public
  def on_change(method = nil, &block)
    @on_change = method ? method : block
  end
end