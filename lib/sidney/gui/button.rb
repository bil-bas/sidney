# encoding: utf-8

require_relative 'element'

module Sidney
module Gui
class Button < Element
  BACKGROUND_COLOR = Color.rgb(100, 100, 100)
  BORDER_COLOR = Color.rgb(150, 150, 150)
  TEXT_COLOR = Color.rgb(255, 255, 255)

  protected
  # @option options [Gosu::Image, nil] icon (nil)
  # @option options [String] text ('')
  def initialize(parent, options = {}, &block)
    options = {
      icon: nil,
      text: ''
    }.merge! options

    @text = options[:text]
    @icon = options[:icon]
    
    super(parent, options)

    if @icon
      if @text.empty?
        rect.width = [@icon.width + padding_x * 2, width].max
        rect.height = [@icon.height + padding_y * 2, height].max
      else
        rect.width = [@icon.width + font.text_width(@text) + padding_x * 3, width].max
        rect.height = [[@icon.height, font_size].max + padding_y * 2, height].max
      end
    else
      rect.width = [font.text_width(@text) + padding_x * 2, width].max
      rect.height = [font_size + padding_y * 2, height].max
    end
  end

  public
  def draw
    $window.draw_box(x, y, width, height, z, BORDER_COLOR, BACKGROUND_COLOR)

    current_x = x + padding_x - 1
    if @icon
      @icon.draw(current_x, y + padding_y, z)
      current_x += @icon.width + padding_x
    end

    unless @text.empty?
      font.draw(@text, current_x, y + padding_y, z, 1, 1, TEXT_COLOR)
    end

    nil
  end

  public
  def clicked_left_mouse_button(sender, x, y)
    # TODO: Play click sound?
    nil
  end
end
end
end