module Gosu
  class Window
    public
    def draw_box(x, y, width, height, z, border_color = nil, fill_color = nil)
      if fill_color
        draw_quad(x, y, fill_color,
                          x + width, y, fill_color,
                          x + width, y + height, fill_color,
                          x, y + height, fill_color, z)
      end

      if border_color
        draw_line(x, y, border_color, x, y + height, border_color, z) # left
        draw_line(x, y, border_color, x + width, y, border_color, z) # top
        draw_line(x + width, y, border_color, x + width, y + height,  border_color, z) # right
        draw_line(x, y + height, border_color, x + width, y + height,  border_color, z) # bottom
      end

      nil
    end

    public
    def shift_down?
      button_down?(Button::KbLeftShift) or button_down?(Button::KbRightShift)
    end

    public
    def control_down?
      button_down?(Button::KbLeftControl) or button_down?(Button::KbRightControl)
    end

    public
    def alt_down?
      button_down?(Button::KbLeftAlt) or button_down?(Button::KbRightAlt) 
    end
  end
end