require_relative 'element'
require_relative 'menu_pane'

module Sidney
module Gui
class CombiBox < Element
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

  # @option options [] :width
  # @option options [] :value
  protected
  def initialize(parent, options = {})
    options = {
      x: 0,
      y: 0,
      height: FONT_SIZE + PADDING_Y * 2,
      width: 0
    }.merge! options

    options[:width] = [options[:width], DEFAULT_WIDTH].max

    @value = options[:value]

    @border_color = 0xffffffff
    @background_color = 0xff666666
    
    @hover_index = 0

    @menu = MenuPane.new do |widget|
      widget.subscribe :select do |widget, value|
        self.value = value
      end
    end

     super(parent, options)
  end

  public
  def add(*args)
    @menu.add(*args)
  end

  public
  def draw
    $window.draw_box(x, y, width, height, z, @border_color, @background_color)
    font.draw(text, x + PADDING_X, y + ((height - FONT_SIZE) / 2).floor, z)

    nil
  end

  public
  def click
    @menu.x = x
    @menu.y = y + height + 1
    $window.game_state_manager.current_game_state.show_menu @menu

    nil
  end
end
end
end