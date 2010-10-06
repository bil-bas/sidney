require 'gosu'
require 'chingu'
require 'texplay'
TexPlay.set_options(caching: false)

module Gosu
class Image
  DEFAULT_TRANSPARENCY_TOLERANCE = 0.0
  
  # Image that is an outline of the image itself [Gosu::Image]
  attr_reader :outline

  # Create a new image which is completely transparent (unless using :color option).
  #
  # === Parameters
  # +width+:: [Fixnum]
  # +height+:: [Fixnum]
  #
  # ==== Options
  # * :color - Colour to fill the new image with.
  #
  # Returns: A new image [Gosu::Image]
  public
  def self.create(width, height, options = {})
    TexPlay.create_image($window, width, height, options)
  end

  # Redraw the outline image, assuming the image has changed.
  public
  def redraw_outline
    if @outline
      @outline.clear
    else
      @outline = Image.create(width + 2, height + 2)
    end

    clear(dest_select: :transparent)

    # Find the top and bottom edges.
    height.times do |y|
      x = 0

      while x and x < width
        if x == 0 and not transparent_pixel?(x, y)
          # If the first pixel is opaque, then put an outline above it.
          @outline.set_pixel(0, y + 1)
          x = 1
        else
          found = line(x, y, width - 1, y, trace: { while_color: :alpha })
          x = found ? found[0] : nil
          @outline.set_pixel(x, y + 1) if x
        end

        if x and x < width
          found = line(x, y, width - 1, y, trace: { until_color: :alpha })
          x = found ? found[0] : width
          @outline.set_pixel(x + 1, y + 1)
        end
      end
    end

    # Find the left and right edges.
    width.times do |x|
      y = 0

      while y and y < height
        if y == 0 and not transparent_pixel?(x, y)
          # If the first pixel is opaque, then put an outline to the left of it.
          @outline.set_pixel(x + 1, 0)
          y = 1
        else
          found = line(x, y, x, height - 1, trace: { while_color: :alpha })
          y = found ? found[1] : nil
          @outline.set_pixel(x + 1, y) if y
        end

        if y and y < height
          found = line(x, y, x, height - 1, trace: { until_color: :alpha })
          y = found ? found[1] : height
          @outline.set_pixel(x + 1, y + 1)
        end
      end
    end

    @outline
  end

  # Crop the image down to a rectangular part of it.
  #
  # === Parameters
  # +box+:: [Chingu::Rect]
  #
  # Returns: The cropped image [Gosu::Image].
  public
  def crop(box)
    if (box.width < width and box.height <= height) or (box.width <= width and box.height < height)
      cropped = Image.create(box.width, box.height)
      cropped.splice self, 0, 0, crop: [box.x, box.y, box.right, box.bottom]
      cropped
    else
      self
    end
  end

  # Finds the smallest rectangle, with coordinates within the image, which cuts off all transparent edges.
  #
  # Returns: The rectangle containing all visible pixels [Chingu::Rect]
  public
  def auto_crop_box(options = {})
    options = { color: :alpha }.merge! options
    box_left, box_top = 0, 0
    box_right, box_bottom = width - 1, height - 1

    color = options[:color]

    # Find where the leftmost column with non-transparent pixels is.
    width.times do |x|
      break if line(x, 0, x, height - 1, trace: { while_color: color })
      box_left += 1
    end

    # Find where the rightmost column with non-transparent pixels is.
    (width - 1).downto(box_left) do |x|
      break if line(x, 0, x, height - 1, trace: { while_color: color })
      box_right -= 1
    end

    # Find where the highest row with non-transparent pixels is.
    height.times do |y|
      break if line(0, y, width - 1, y, trace: { while_color: color })
      box_top += 1
    end

    # Find where the lowest row with non-transparent pixels is.
    (height - 1).downto(box_top) do |y|
      break if line(0, y, width - 1, y, trace: { while_color: color })
      box_bottom -= 1
    end

    Chingu::Rect.new(box_left, box_top, box_right - box_left + 1, box_bottom - box_top + 1)
  end

  # Used to create images directly from raw data by providing the methods expected by Gosu::Image when it loads from an
  # RMagick image.
  class BlobData
    # Width of the image [Fixnum].
    attr_reader :columns
    # Height of the image [Fixnum]
    attr_reader :rows

    # Get the raw image data in RGBA format [String]
    def to_blob; @data; end

    # +data+:: String of unsigned bytes in RGBA order [String of length height x width x 4]
    # +width+:: Width of the image [Fixnum]
    # +height+:: Height of the image [Fixnum]
    protected
    def initialize(data, width, height)
      @data, @columns, @rows = data, width, height
    end

    # Convert into a Gosu::Image
    #
    # === Parameters
    # ==== Options
    # * +:tileable+ - Are the edges of the image sharp? [Boolean, defaults to false]
    public
    def to_image(options = {})
      options = { tileable: false }.merge!(options)
      Image.new($window, self, options[:tileable], options)
    end
  end

  # Generate a new image from raw blob data.
  #
  # === Parameters
  # +data+:: String of unsigned bytes in RGBA order [String of length height x width x 4]
  # +width+:: Width of the image [Fixnum]
  # +height+:: Height of the image [Fixnum]
  # ==== Options
  # * +:tileable+You are a - Are the edges of the image sharp? [Boolean, defaults to false]
  #
  # Returns: A new image [Gosu::Image]
  public
  def self.from_blob(data, width, height, options = {})
    options = { tileable: false }.merge!(options)
    BlobData.new(data, width, height).to_image(options)
  end

  # Manipulates an image with DevIL within a block, before returning the newly manipulated version.
  #
  # Returns: The manipulated image [Gosu::Image]
  public
  def as_devil
    raise ArgumentError, "Must provide a block" unless block_given?

    devil_image = Devil.from_blob(Image.from_blob(to_blob, width, height).to_blob, width, height) # to_devil & to_blob are broken!.
    devil_image.flip # TODO: Fix devil?
    ret_val = yield devil_image
    devil_image.delete
    
    ret_val
  end

  def mirror
    as_devil do |devil|
      devil.mirror
      devil.to_gosu($window)
    end
  end

  def flip
    as_devil do |devil|
      devil.flip
      devil.to_gosu($window)
    end
  end
end

    class Window
        # Render directly into an existing image, optionally only to a specific region of that image.
        #
        # Since this operation utilises the window's back buffer, the image (or clipped area, if specified) cannot be larger than the
        # window itself. Larger images can be rendered to only in separate sections using :clip_to areas, each no larger
        # than the window).
        #
        # @note *Warning!* This operation will corrupt an area of the screen, at the bottom left corner, equal in size to the image rendered to (or the clipped area), so should be performed in #draw _before_ any other rendering.
        #
        # @note The final alpha of the image will be 255, regardless of what it started with or what is drawn onto it.
        #
        # @example
        #   class Gosu
        #     class Window
        #       def draw
        #         # Always render images before regular drawing to the screen.
        #         unless @rendered_image
        #           @rendered_image = TexPlay.create_image(self, 300, 300, :color => :blue)
        #           render_to_image(@rendered_image) do
        #             @an_image.draw 0, 0, 0
        #             @another_image.draw 130, 0, 0
        #             draw_line(0, 0, Color.new(255, 0, 0, 0), 100, 100, Color.new(255, 0, 0, 0), 0)
        #             @font.draw("Hello world!", 0, 50, 0)
        #           end
        #         end
        #
        #         # Perform regular screen rendering.
        #         @rendered_image.draw 0, 0
        #       end
        #     end
        #   end
        #
        #
        # @param [Gosu::Image] image Existing image to render onto.
        # @option options [Array<Integer>] :clip_to ([0, 0, image.width, image.height]) Area of the image to render into. This area cannot be larger than the window, though the image may be.
        # @option options [Boolean] :clear (true) Whether to clear the screen again after rendering has occurred.
        # @return [Gosu::Image] The image that has been rendered to.
        # @yield to a block that renders to the image.
        def render_to_image(image, options = {})
            raise ArgumentError, "image parameter must be a Gosu::Image to be rendered to" unless image.is_a? Gosu::Image
            raise ArgumentError, "rendering block required" unless block_given?

            options = {
                :clip_to => [0, 0, image.width, image.height],
                :clear => true
            }.merge options

            texture_info = image.gl_tex_info
            tex_name = texture_info.tex_name
            x_offset = (texture_info.left * Gosu::MAX_TEXTURE_SIZE).to_i
            y_offset = (texture_info.top * Gosu::MAX_TEXTURE_SIZE).to_i

            raise ArgumentError, ":clip_to rectangle must contain exactly 4 elements" unless options[:clip_to].size == 4

            left, top, width, height = *(options[:clip_to].map {|n| n.to_i })

            raise ArgumentError, ":clip_to rectangle cannot be wider or taller than the window" unless width <= self.width and height <= self.height
            raise ArgumentError, ":clip_to rectangle width and height must be positive" unless width > 0 and height > 0

            right = left + width - 1
            bottom = top + height - 1

            unless (0...image.width).include? left and (0...image.width).include? right and
                   (0...image.height).include? top and (0...image.height).include? bottom
                raise ArgumentError, ":clip_to rectangle out of bounds of the image"
            end

            # Since to_texture copies an inverted copy of the screen, what the user renders needs to be inverted first.
            scale(1, -1) do
                translate(-left, -top - self.height) do
                    # TODO: Once Gosu is fixed, we can just pass width/height to clip_to
                    clip_to(left, top, width, height) do
                        # Draw over the background (which is assumed to be blank) with the original image texture,
                        # to get us to the base image.
                        image.draw(0, 0, 0)
                        flush

                        # Allow the user to overwrite the texture.
                        yield
                    end

                    # Copy the modified texture back from the screen buffer to the image.
                    to_texture(tex_name, x_offset + left, y_offset + top, 0, 0, width, height)

                    # Clear the clipped zone to black again, ready for the regular screen drawing.
                    if options[:clear]
                        clear = Gosu::Color.new(255, 0, 0, 0)
                        draw_quad(left, top, clear,
                                  right, top, clear,
                                  right, bottom, clear,
                                  left, bottom, clear)
                    end
                end
            end

            image
        end
    end
end