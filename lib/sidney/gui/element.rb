require_relative '../gosu_ext'
require_relative '../event'

module Sidney
module Gui
# An element within the GUI environment.
# @abstract
class Element
  include Event

  DEFAULT_FONT_SIZE = 15
  FONT_NAME = File.join(ROOT_PATH, 'media', 'fonts', 'SFPixelate.ttf')
  PADDING_X, PADDING_Y = 10, 5
  BACKGROUND_COLOR = Color.rgb(0, 0, 0)
  
  attr_reader :rect, :z, :tip, :font_size

  attr_accessor :parent

  @@fonts = {}
  def self.font(size = DEFAULT_FONT_SIZE)
    @@fonts[size] ||= Font.new($window, FONT_NAME, size)
  end

  def font; self.class.font @font_size; end
  def x; rect.x; end
  def x=(value); rect.x = value; end
  def y; rect.y; end
  def y=(value); rect.y = value; end
  def width; rect.width; end
  def height; rect.height; end

  def initialize(parent, options = {}, &block)
    options = {
      x: 0,
      y: 0,
      z: ZOrder::GUI,
      width: 0,
      height: 0,
      tip: '',
      font_size: DEFAULT_FONT_SIZE
    }.merge! options

    @parent = parent

    @rect = Rect.new(options[:x], options[:y], options[:width], options[:height])
    @z = options[:z]
    @tip = options[:tip]
    @font_size = options[:font_size]
  end

  # Called by decendents when all inititialization is complete.
  protected
  def post_init(&block)
    @parent.add self if @parent
    yield self if block_given?
  end

  # Check if a point (screen coordinates) is over the element.
  public
  def hit?(x, y)
    @rect.collide_point?(x, y)
  end

  # Hover the mouse over the element.
  public
  def hover(x, y)
    nil
  end

  # Mouse moves over the element.
  def enter
    nil
  end

  # Mouse leaves the element.
  def leave
    nil
  end

  # Clicked the mouse button (usually only the left one) on the element.
  def click
    nil
  end

  # Redraw the element.
  def draw
    nil
  end

  # Update the element.
  def update
    nil
  end
end
end
end