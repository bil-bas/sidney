require_relative 'gui_element'

module Sidney
class MenuPane < GuiElement
  class Item
    attr_reader :text, :value, :shortcut

    def enabled?
      @enabled
    end

    def enabled=(value)
      @enabled = value
    end

    # === Parameters
    # +value+:: Value if the user picks this item [Any]
    # +text+:: Descriptive text shown to the user [String]
    # +options+:: [Hash]
    # * +:enabled+ - [Boolean]
    # * +:shortcut+ - [String]
    protected
    def initialize(value, text, options = {})
      options = {
        enabled: true
      }.merge! options

      @value, @text = value, text
      @enabled = [true, false].include?(options[:enabled]) ? options[:enabled] : true
      @shortcut = options[:shortcut] || nil

      yield self if block_given?
    end
  end


  attr_reader :items, :index

  def line_height; FONT_SIZE + PADDING_Y * 2; end
  
  public
  def initialize(options = {})
    options = {
      z: ZOrder::MENU
    }.merge! options

    @items = []

    @background_color = 0xff333333
    @hover_background_color = 0xff999999
    @border_color = nil
    
    @index = nil # The index of the item hovered over.

    super(nil, options)
  end

  def index(value)
    @items.index(find(value))
  end

  def find(value)
    @items.find { |item| item.value == value }
  end

  def size
    @items.size
  end

  def [](index)
    @items[index]
  end

  def add(*args)
    @items << Item.new(*args)
    recalc
    self
  end

  def add_separator
    @@sep_num ||= 0
    @@sep_num += 1
    @items << Item.new(:"_sep_#{@@sep_num}", '---', enabled: false)
    recalc
    self
  end

  public
  def recalc
    @rect.height = line_height * @items.size
    @items.each do |item|
      text = item.text
      text += "  (#{item.shortcut})" if item.shortcut
      rect.width = [rect.width, font.text_width(text) + PADDING_X * 2].max
    end

    @items.size
  end

  public
  def draw
    $window.draw_box(rect.x, rect.y, rect.width, rect.height, z, @border_color, @background_color)

    @items.each_with_index do |item, i|
      y = rect.y + (line_height * i)

      if item.enabled? and i == @index
        $window.draw_box(rect.x, y, rect.width, line_height, z, nil, @hover_background_color)
      end

      color = item.enabled? ? 0xffffffff : 0xff888888
      font.draw(item.text, rect.x + PADDING_X, y + ((line_height - FONT_SIZE) / 2).floor, z, 1, 1, color)

      if item.shortcut
        font.draw_rel("(#{item.shortcut})", rect.right - PADDING_X, y + ((line_height - FONT_SIZE) / 2).floor, z, 1, 0, 1, 1, color)
      end
    end

    nil
  end

  public
  def hover(x, y)
    @index = ((y - rect.y) / line_height).floor

    nil
  end

  public
  def leave
    @index = nil
  end

  public
  def click
    if @items[@index].enabled?
      $window.game_state_manager.current_game_state.hide_menu
      publish(:select, @items[@index].value)
    end

    nil
  end
end
end