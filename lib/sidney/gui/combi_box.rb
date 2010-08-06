require 'gui/gui_element'
require 'gui/menu_pane'
require 'event'

class CombiBox < GuiElement
  include Event

  event :change

  public
  attr_accessor :index

  public
  def index; @menu.index(@value) end
  def value; @value; end
  def text; @menu.find(@value).text; end
  
  public
  def value=(value)
    if @value != value
      @value = value
      publish_change(@value)
    end
  end

  public
  def index=(index)
    if index.between?(0, @menu.size - 1)
      self.value = @menu[index].value
    end
  end

  def rect; @rect.dup; end

  # Options are { value => text } pairs
  protected
  def initialize(x, y, width, height, initial_value)
    super(x, y, width, height, ZOrder::GUI)

    @value = initial_value

    @border_color = 0xffffffff
    @background_color = 0xff666666
    
    @open = false
    @hover_index = 0

    @menu = MenuPane.new(rect.left, rect.bottom + 1, z + 0.01) do |widget|
      widget.on_select do |widget, value|
        self.value = value
      end
    end

    yield self if block_given?
  end

  public
  def add(*args)
    @menu.add(*args)
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
end