# encoding: utf-8

require_relative 'gui_state'
require_relative '../gosu_ext/color'
require_relative '../gui/history'
require_relative '../log'

module Sidney
class EditObject < GuiState
  include Log
  
  MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT = Grid::WIDTH * 3, Grid::HEIGHT * 3
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
      f1: ->{ push_game_state Chingu::GameStates::Popup.new(text: t('edit_object.help', general: t('help'))) },
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
    @image.splice(@object.image, @object.x - IMAGE_X, @object.y - @object.height - IMAGE_Y)
    
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

    unless @transparent_small
      row = [[80, 80, 80, 255], [120, 120, 120, 255]]
      blob = [row, row.reverse]
      # Small transparent checkerboard drawn behind colour wells.
      @transparent_small = Image.from_blob(blob.flatten.pack('C*'), 2, 2)
      # Large grey checkerboard drawn behind the object being edited.
      @transparent_large = Image.create(Grid::WIDTH + Grid::CELL_WIDTH, Grid::HEIGHT + Grid::CELL_HEIGHT)
      @transparent_large.rect 0, 0, @transparent_large.width - 1, @transparent_large.height - 1,
                              filled: true, texture: @transparent_small
    end

    #$window.draw_box(rect.x, rect.y, rect.right, rect.bottom, 100000, nil, 0xa0000000)

    $window.translate(rect.x, rect.y) do
      $window.clip_to(0, 0, rect.width, rect.height) do
        @transparent_large.draw(((grid.offset_x % Grid::CELL_WIDTH) - Grid::CELL_WIDTH) * grid.scale,
                                ((grid.offset_y % Grid::CELL_HEIGHT) - Grid::CELL_HEIGHT) * grid.scale,
                                100000, 4 * grid.scale, 4 * grid.scale, 0xa0ffffff)
        $window.scale(grid.scale) do
          @image.draw(grid.offset_x + IMAGE_X, grid.offset_y + IMAGE_Y, 100001)
        end
      end
    end

    x, y = grid.rect.right, grid.rect.top
    @transparent_small.draw x + 10, y + 50, ZOrder::GUI, 25, 25
    $window.draw_box x + 10, y + 50, 50, 50, ZOrder::GUI, 0xffffffff, Gosu::Color.from_texplay(@draw_color)

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
    @object.x = box.x + IMAGE_X
    @object.y = box.y + IMAGE_Y + @image.height
    
    @image = nil

    @object.show!

    log.info { "Saved image" }

    nil
  end
end
end