module Gosu
  class Window
    public
    def draw_box(x, y, width, height, z, border_color = nil, fill_color = nil)
      if fill_color
        $window.draw_quad(x, y, fill_color,
                          x + width, y, fill_color,
                          x + width, y + height, fill_color,
                          x, y + height, fill_color, z)
      end

      if border_color
        $window.draw_line(x, y, border_color, x, y + height, border_color, z) # left
        $window.draw_line(x, y, border_color, x + width, y, border_color, z) # top
        $window.draw_line(x + width, y, border_color, x + width, y + height,  border_color, z) # right
        $window.draw_line(x, y + height, border_color, x + width, y + height,  border_color, z) # bottom
      end

      nil
    end
  end
end