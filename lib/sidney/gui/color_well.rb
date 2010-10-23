# encoding: utf-8

require_relative 'radio_button'

module Sidney
module Gui
  class ColorWell < RadioButton
    DEFAULT_COLOR = Color.rgb(0, 0, 0)
    BORDER_COLOR_CHECKED = Color.rgb(255, 255, 255)
    BORDER_COLOR_UNCHECKED = Color.rgb(100, 100, 100)
    OUTLINE_COLOR = Color.rgb(0, 0, 0)

    DEFAULT_SIZE = DEFAULT_FONT_SIZE + 2 * DEFAULT_PADDING_Y

    attr_accessor :color
    def value; @color.dup; end

    # Manages a group of ColorWells.
    class Group < RadioButton::Group
    end

    protected
    def initialize(parent, options = {}, &block)
      options = {
        color: DEFAULT_COLOR.dup,
        width: DEFAULT_SIZE,
        height: DEFAULT_SIZE,
      }.merge! options

      @color = options[:color]

      super(parent, nil, options)
    end

    public
    def draw
      $window.draw_box x, y, width, height, z, nil, checked? ? BORDER_COLOR_CHECKED : BORDER_COLOR_UNCHECKED
      $window.draw_box x + 2, y + 2, width - 4, height - 4, z, nil, OUTLINE_COLOR
      $window.draw_box x + 3, y + 3, width - 6, height - 6, z, nil, @color

      nil
    end
  end
end
end