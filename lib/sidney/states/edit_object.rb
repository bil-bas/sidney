# encoding: utf-8

require 'states/gui_state'
require 'gosu_ext/color'
require 'gui/history'
require 'log'

module Sidney
class EditObject < GuiState
  include Log
  
  MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT = 208 * 3, 208 * 3
  IMAGE_X = - MAX_IMAGE_WIDTH / 3
  IMAGE_Y = - MAX_IMAGE_HEIGHT / 3

  INITIAL_DRAW_COLOR = [1, 1, 1, 1]

  protected
  def grid
    previous_game_state.grid
  end

  protected
  def zoom_box
    previous_game_state.zoom_box
  end

  protected
  def cursor
    $window.cursor
  end

  protected
  def initialize
    super()

    add_inputs(
      released_escape: ->{ save_changes; pop_game_state },
      g: ->{ grid.toggle_overlay if $window.holding_control? },
      f1: ->{ push_game_state Chingu::GameStates::Popup.new(text: t('edit_object.help', :general => t('help'))) },
      mouse_wheel_up: ->{ zoom_box.index += 1 },
      mouse_wheel_down: ->{ zoom_box.index -= 1 },
      holding_left: ->{ grid.left },
      holding_right: ->{ grid.right },
      holding_up: ->{ grid.up },
      holding_down: ->{ grid.down }
    )

    @draw_color = INITIAL_DRAW_COLOR

    nil
  end

  public
  def object=(object)
    @object = object
    @object.hide!

    @image = Image.create(MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT)
    @image.splice(@object.image, @object.x - @object.width * 0.5 - IMAGE_X, @object.y - @object.height - IMAGE_Y)
    
    object
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
      @image.set_pixel(x - IMAGE_X, y - IMAGE_Y, color: @draw_color)
    end

    nil
  end

  protected
  def holding_right_mouse_button
    x, y = cursor.x, cursor.y
    if grid.hit?(x, y)
      x, y = grid.screen_to_grid(x, y)
      @draw_color = @image.get_pixel(x - IMAGE_X, y - IMAGE_X)
    end

    nil
  end

  public
  def draw
    previous_game_state.draw
    rect = grid.rect
    $window.draw_box(rect.x, rect.y, rect.right, rect.bottom, 100000, nil, 0xa0000000)

    $window.translate(rect.x, rect.y) do
      $window.clip_to(rect.x, rect.y, rect.width, rect.height) do
        $window.scale(grid.scale) do
          @image.draw(grid.offset_x + IMAGE_X, grid.offset_y + IMAGE_Y, 100001)
        end
      end
    end

    x, y = grid.rect.right, grid.rect.top
    $window.draw_box x + 10, y + 50, 50, 50, ZOrder::GUI, 0xffffffff, Gosu::Color.from_rgba(*@draw_color.map {|c| (c * 255).to_i })

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
    end

    log.info { "Image re-sized from #{@object.image.width}x#{@object.image.height} to #{box.width}x#{box.height}" }

    # Replace the old image with the temporary one.
    @object.image = @image
    @object.size = [@image.width, @image.height]
    @object.x = box.x + IMAGE_X + @image.width / 2
    @object.y = box.y + IMAGE_Y + @image.height
    
    @image = nil

    @object.show!

    log.info { "Saved image" }

    nil
  end
end
end