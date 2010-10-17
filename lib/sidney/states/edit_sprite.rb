# encoding: utf-8

require_relative 'edit_base'
require_relative '../gosu_ext/color'
require_relative '../gui/history'
require_relative '../log'

module Sidney
  class EditSprite < EditBase
    include Log

    MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT = Grid::WIDTH * 3, Grid::HEIGHT * 3
    IMAGE_X = - MAX_IMAGE_WIDTH / 3
    IMAGE_Y = - MAX_IMAGE_HEIGHT / 3

    INITIAL_DRAW_COLOR = [1, 1, 1, 1]

    protected
    def initialize
      super()

      add_inputs(
        released_escape: ->{ save_changes; pop_game_state },
        g: ->{ grid.toggle_overlay if $window.holding_control? },
        f1: ->{ push_game_state Chingu::GameStates::Popup.new(text: t('edit_sprite.help', general: t('help'))) },
        mouse_wheel_up: ->{ zoom_box.index += 1 },
        mouse_wheel_down: ->{ zoom_box.index -= 1 },
        holding_left: ->{ grid.left },
        holding_right: ->{ grid.right },
        holding_up: ->{ grid.up },
        holding_down: ->{ grid.down },
        f1: ->{ push_game_state Chingu::GameStates::Popup.new(text: t('edit_sprite.help', general: t('help'))) }
      )

      @draw_color = INITIAL_DRAW_COLOR

      nil
    end

    public
    def init(sprite, object)
      @sprite, @object = sprite, object
      @sprite.hide!

      @image = Image.create(MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT)
      @image.splice(@sprite.sprite.image, @object.x + @sprite.x + @sprite.sprite.x_offset - IMAGE_X, @object.y + @sprite.y + @sprite.sprite.y_offset - IMAGE_Y)

      @sprite
    end

    public
    def setup
      log.info { "Started editing sprite image" }

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
        @draw_color = @image.get_pixel(x - IMAGE_X, y - IMAGE_Y)
      end

      nil
    end

    public
    def draw
      previous_game_state.draw
      $window.flush # Ensure that all assets drawn by the previous mode are rendered.

      unless @transparent_small
        row = [[80, 80, 80, 255], [120, 120, 120, 255]]
        blob = [row, row.reverse]
        # Small transparent checkerboard drawn behind colour wells.
        @transparent_small = Image.from_blob(blob.flatten.pack('C*'), 2, 2, caching: true)
        # Large grey checkerboard drawn behind the sprite being edited.
        @transparent_large = Image.create(Grid::WIDTH + Grid::CELL_WIDTH, Grid::HEIGHT + Grid::CELL_HEIGHT)
        @transparent_large.rect 0, 0, @transparent_large.width - 1, @transparent_large.height - 1,
                                fill: true, texture: @transparent_small
      end

      grid.draw_with_respect_to do
        @transparent_large.draw(((grid.offset_x % Grid::CELL_WIDTH) - Grid::CELL_WIDTH - grid.offset_x),
                               ((grid.offset_y % Grid::CELL_HEIGHT) - Grid::CELL_HEIGHT - grid.offset_y),
                               100000, 4, 4, Color.rgba(255, 255, 255, 150))

        @image.draw(IMAGE_X, IMAGE_Y, 100001)
      end

      # Draw a transparent checkerboard, then draw the colour on top of that.
      rect = grid.rect
      x, y = rect.right + 10, rect.top + 50
      @transparent_small.draw x, y, ZOrder::GUI, 25, 25
      $window.draw_box x, y, 50, 50, ZOrder::GUI, 0xffffffff, Gosu::Color.from_texplay(@draw_color)

      super
    end

    # Save the edited image to the sprite we are editing.
    protected
    def save_changes
      old_width, old_height = @sprite.sprite.image.width, @sprite.sprite.image.height
      # Crop the temporary image if necessary.
      box = @image.auto_crop_box

      if box.width != @image.width or box.height != @image.height
        @image = @image.crop(box)
      end

      log.info { "Image re-sized from #{@sprite.sprite.image.width}x#{@sprite.sprite.image.height} to #{box.width}x#{box.height}" }

      # Replace the old image with the temporary one.
      @sprite.sprite.image = @image
      @sprite.sprite.x_offset = box.x + IMAGE_X - @sprite.x - @object.x
      @sprite.sprite.y_offset = box.y + IMAGE_Y - @sprite.y - @object.y
      #@sprite.sprite.update

      @image = nil

      @sprite.show!

      log.info { "Saved sprite image" }

      nil
    end
  end
end