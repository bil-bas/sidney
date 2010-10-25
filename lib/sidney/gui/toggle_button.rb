# encoding: utf-8

require_relative 'button'

module Sidney
module Gui
  class ToggleButton < Button
    ON_BORDER_COLOR = Color.new(255, 255, 0)

    def on?; @on; end
    def on=(value); @on = value; update_status; end

    protected
    def initialize(parent, options = {}, &block)
      options = {
        on: false
      }.merge! options

      @on = options[:on]

      @on_text = options[:on_text] || options[:text] || ''
      @on_icon = options[:on_icon] || options[:icon]
      @on_tip = options[:on_tip] || options[:tip] || ''

      @off_text = options[:off_text] || options[:text] || ''
      @off_icon = options[:off_icon] || options[:icon]
      @off_tip = options[:off_tip] || options[:tip] || ''

      super(parent, options)

      update_status
    end

    protected
    def update_status
      if @on
        @text = @on_text
        @icon = @on_icon
        @tip = @on_tip
      else
        @text = @off_text
        @icon = @off_icon
        @tip = @off_tip
      end

      nil
    end

    public
    def clicked_left_mouse_button(sender, x, y)
      @on = (not @on)
      update_status

      super
    end

    public
    def draw
      super

      $window.draw_box x, y, width, height, z, ON_BORDER_COLOR if on?

      nil
    end
  end
end
end