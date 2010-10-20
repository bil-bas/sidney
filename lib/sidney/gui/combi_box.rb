require_relative 'gui_element'
require_relative 'menu_pane'

module Sidney
class CombiBox < GuiElement
  DEFAULT_WIDTH = FONT_SIZE * 6

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
      publish :change, @value
    end
  end

  public
  def index=(index)
    if index.between?(0, @menu.size - 1)
      self.value = @menu[index].value
    end
  end

  protected
  def initialize(x, y, initial_value, options = {})
    options = {
            width: DEFAULT_WIDTH
    }.merge! options

    @value = initial_value

    @border_color = 0xffffffff
    @background_color = 0xff666666
    
    @hover_index = 0

    height = FONT_SIZE + PADDING_Y * 2
    @menu = MenuPane.new(x, y + height) do |widget|
      widget.subscribe :select do |widget, value|
        self.value = value
      end
    end

    super(x, y, options[:width], height, ZOrder::GUI, options)
  end

  public
  def add(*args)
    @menu.add(*args)
  end

  public
  def draw
    $window.draw_box(rect.x, rect.y, rect.width, rect.height, z, @border_color, @background_color)
    font.draw(text, rect.x + PADDING_X, rect.y + ((rect.height - FONT_SIZE) / 2).floor, z)

    nil
  end

  public
  def click
    p "clicking #{@menu} #{@menu.height}"
    p $window.game_state_manager.current_game_state
    $window.game_state_manager.current_game_state.show_menu @menu
    p "clicked"
    nil
  end
end
end