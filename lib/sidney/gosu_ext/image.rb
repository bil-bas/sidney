module Gosu
class Image
  # Image that is an outline of the image itself [Gosu::Image]
  attr_reader :outline

  # Create a new image which is completely transparent (unless using :color option).
  #
  # === Parameters
  # +width+:: [Int]
  # +height+:: [Int]
  # +options+:: [Hash]
  # * :color - Colour to fill the new image with.
  public
  def self.create(width, height, options = {})
    TexPlay.create_image($window, width, height, options)
  end

  # Clear all transparent colors to transparent black.
  public
  def clear_transparency
    # TODO: Hopefully TexPlay author will fix this!
    #rect 0, 0, width, height, :filled => true, :color => :alpha, :dest_select => :transparent

    nil
  end

  # Redraw the outline image, assuming the image has changed.
  public
  def redraw_outline
    if @outline
      @outline.rect 0, 0, @outline.width, @outline.height, :fill => true, :color => [0, 0, 0, 0]
    else
      @outline = Image.create(width + 2, height + 2)
    end

    clear_transparency

    # Find the top and bottom edges.
    height.times do |y|
      x = 0

      while x and x < width
        if x == 0 and not transparent_pixel?(x, y)
          # If the first pixel is opaque, then put an outline above it.
          @outline.set_pixel(0, y + 1, :color => :white)
          x = 1
        else
          found = line(x, y, width - 1, y, :trace => { :while_color => :alpha })
          x = found ? found[0] : nil
          @outline.set_pixel(x, y + 1, :color => :white) if x
        end

        if x and x < width
          found = line(x, y, width - 1, y, :trace => { :until_color => :alpha })
          x = found ? found[0] : width
          @outline.set_pixel(x + 1, y + 1, :color => :white)
        end
      end
    end

    # Find the left and right edges.
    width.times do |x|
      y = 0

      while y and y < height
        if y == 0 and not transparent_pixel?(x, y)
          # If the first pixel is opaque, then put an outline to the left of it.
          @outline.set_pixel(x + 1, 0, :color => :white)
          y = 1
        else
          found = line(x, y, x, height - 1, :trace => { :while_color => :alpha })
          y = found ? found[1] : nil
          @outline.set_pixel(x + 1, y, :color => :white) if y
        end
        
        if y and y < height
          found = line(x, y, x, height - 1, :trace => { :until_color => :alpha })
          y = found ? found[1] : height
          @outline.set_pixel(x + 1, y + 1, :color => :white)
        end
      end
    end

    @outline
  end

  # Crop the image down to a rectangular part of it.
  #
  # === Parameters
  # +box+:: [Rect]
  #
  # Returns: The cropped image [Gosu::Image].
  public
  def crop(box)
    if (box.width < width and box.height <= height) or (box.width <= width and box.height < height)
      cropped = Image.create(box.width, box.height)
      cropped.splice self, 0, 0, :crop => [box.x, box.y, box.right, box.bottom]
      cropped
    else
      self
    end
  end

  # Finds the smallest rectangle, with coordinates within the image, which cuts off all transparent edges.
  #
  # Returns: The rectangle containing all visible pixels [Chingu::Rect]
  public
  def auto_crop_box
    box_left, box_top = 0, 0
    box_right, box_bottom = width - 1, height - 1

    clear_transparency

    # Find where the leftmost column with non-transparent pixels is.
    width.times do |x|
      break if line(x, 0, x, height - 1, :trace => { :while_color => :alpha })
      box_left += 1
    end

    # Find where the rightmost column with non-transparent pixels is.
    (width - 1).downto(box_left) do |x|
      break if line(x, 0, x, height - 1, :trace => { :while_color => :alpha })
      box_right -= 1
    end

    # Find where the highest row with non-transparent pixels is.
    height.times do |y|
      break if line(0, y, width - 1, y, :trace => { :while_color => :alpha })
      box_top += 1
    end

    # Find where the lowest row with non-transparent pixels is.
    (height - 1).downto(box_top) do |y|
      break if line(0, y, width - 1, y, :trace => { :while_color => :alpha })
      box_bottom -= 1
    end

    Rect.new(box_left, box_top, box_right - box_left + 1, box_bottom - box_top + 1)
  end
end
end