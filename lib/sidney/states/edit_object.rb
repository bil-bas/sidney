require 'gui/history'
require 'log'

module Sidney
class EditObject < GameState
  include Log
  
  MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT = 416, 416

  protected
  def grid
    game_state_manager.previous.grid
  end

  protected
  def zoom_box
    game_state_manager.previous.zoom_box
  end

  protected
  def cursor
    $window.cursor
  end

  protected
  def initialize(object)
    @object = object

    super  

    @object.hide!

    self.input = {
      :holding_left_mouse_button => :holding_left_mouse_button,
      :holding_right_mouse_button => :holding_right_mouse_button,
      :released_escape => lambda { save_changes; game_state_manager.pop },
      :g => lambda { grid.toggle_overlay if $window.control_down? },
      :wheel_up => lambda { zoom_box.index += 1 },
      :wheel_down => lambda { zoom_box.index -= 1 },
      :holding_left => lambda { grid.left },
      :holding_right => lambda { grid.right },
      :holding_up => lambda { grid.up },
      :holding_down => lambda { grid.down },
    }

    @image = TexPlay.create_image($window, MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT)
    @image.splice(@object.image, @object.x - @object.width * 0.5, @object.y - @object.height)

    nil
  end

  public
  def setup
    log.info { "Started editing image" }

    nil
  end

  protected
  def holding_left_mouse_button
    x, y = cursor.x, cursor.y
    if grid.hit?(x, y)
      x, y = grid.screen_to_grid(x, y)
      @image.set_pixel(x, y, :color => :red)
    end

    nil
  end

  protected
  def holding_right_mouse_button
    x, y = cursor.x, cursor.y
    if grid.hit?(x, y)
      x, y = grid.screen_to_grid(x, y)
      @image.set_pixel(x, y, :color => :alpha)
    end

    nil
  end

  public
  def draw
    game_state_manager.previous.draw
    rect = grid.rect
    $window.draw_box(rect.x, rect.y, rect.right, rect.bottom, 100000, nil, 0xa0000000)

    $window.translate(rect.x, rect.y) do
      $window.clip_to(rect.x, rect.y, rect.width, rect.height) do
        $window.scale(grid.scale) do
          @image.draw(grid.offset_x, grid.offset_y, 100001)
        end
      end
    end

    nil
  end

  # Save the edited image to the object we are editing.
  protected
  def save_changes
    old_width, old_height = @object.image.width, @object.image.height
    # Crop the temporary image if necessary.
    box = @image.auto_crop_box
    if box.width != @image.width or box.height != @image.height
      @image = @image.crop(box)
      # TODO: correct x/y      
    end

    log.info { "Image re-sized from #{@object.image.width}x#{@object.image.height} to #{box.width}x#{box.height}" }

    # Replace the old image with the temporary one.
    @object.image = @image
    @object.size = [@image.width, @image.height]
    @object.x -= (@image.width - old_width * 2) / 2
    @object.y += old_height - @image.height / 2

    log.info { "Saved image" }

    nil
  end

  public
  def finalize
    # Ensure the object is visible again, since we hid it while editing.
    @object.show!
    log.info { "Stopped editing image"}

    nil
  end
end
end