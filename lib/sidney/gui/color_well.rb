# encoding: utf-8

require_relative 'radio_button'

module Sidney
module Gui
  class ColorWell < RadioButton
    DEFAULT_COLOR = Color.rgb(0, 0, 0)
    DEFAULT_BORDER_COLOR_CHECKED = Color.rgb(255, 255, 255)
    DEFAULT_BORDER_COLOR_UNCHECKED = Color.rgb(100, 100, 100)

    OUTLINE_COLOR = Color.rgb(0, 0, 0)

    DEFAULT_SIZE = DEFAULT_FONT_SIZE + 2 * DEFAULT_PADDING_Y

    attr_accessor :color

    # Manages a group of ColorWells.
    class Group < RadioButton::Group
    end

    alias_method :value, :color

    protected
    def initialize(parent, options = {}, &block)
      options = {
        width: DEFAULT_SIZE,
        height: DEFAULT_SIZE,
        color: DEFAULT_COLOR.dup,
        border_color_checked: DEFAULT_BORDER_COLOR_CHECKED.dup,
        border_color_unchecked: DEFAULT_BORDER_COLOR_UNCHECKED.dup,
      }.merge! options

      super(parent, nil, options)
    end

    protected
    def draw_background
      super

      $window.draw_box x + 2, y + 2, width - 4, height - 4, z, nil, OUTLINE_COLOR

      nil
    end

    protected
    def draw_foreground
      $window.draw_box x + 3, y + 3, width - 6, height - 6, z, nil, @color

      nil
    end
  end
end
end