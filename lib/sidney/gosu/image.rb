module Gosu
class Image
  def outline
    @outline
  end

  def redraw_outline
    if @outline
      @outline.rect 0, 0, @outline.width, @outline.height, :fill => true, :color => [0, 0, 0, 0]
    else
      @outline = TexPlay.create_blank_image($window, width + 2, height + 2)
    end

    (-1..height).each do |y|
      (-1..width).each do |x|
        pixel = get_pixel(x, y)
        if pixel.nil? or pixel[3] == 0
          found_edge = false
          ((x - 1)..(x + 1)).each do |x_look|
            ((y - 1)..(y + 1)).each do |y_look|
              pixel = get_pixel(x_look, y_look)
              unless (x == x_look and y == y_look) or pixel.nil? or pixel[3] == 0
                @outline.set_pixel(x + 1, y + 1, :white)
                found_edge = true
                break
              end
              break if found_edge
            end

            break if found_edge
          end
        end
      end
    end

    @outline
  end
end
end