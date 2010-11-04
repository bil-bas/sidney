# encoding: utf-8

require_relative 'edit_base'
require_relative '../gosu_ext'
require_relative '../log'

module Sidney
  class EditSprite < EditBase
    include Log

    MAX_IMAGE_WIDTH, MAX_IMAGE_HEIGHT = Grid::WIDTH * 3, Grid::HEIGHT * 3
    IMAGE_X = - MAX_IMAGE_WIDTH / 3
    IMAGE_Y = - MAX_IMAGE_HEIGHT / 3

    INITIAL_DRAW_COLOR = Color.rgba(255, 255, 255, 255)

    protected
    def initialize
      super()

      add_inputs(
        released_escape: ->{ save_changes; pop_game_state },
        g: ->{ grid.toggle_overlay if $window.holding_control? },
        f1: ->{ push_game_state GameStates::Popup.new(text: t('edit_sprite.help', general: t('help'))) },
        mouse_wheel_up: ->{ zoom_box.index += 1 },
        mouse_wheel_down: ->{ zoom_box.index -= 1 },
        holding_left: ->{ grid.left },
        holding_right: ->{ grid.right },
        holding_up: ->{ grid.up },
        holding_down: ->{ grid.down },
        holding_left_mouse_button: :holding_left_mouse_button,
        holding_right_mouse_button: :holding_right_mouse_button
      )

      @state_bar = VerticalPacker.new(nil, padding: 0) do |packer|
        @color_picker = packer.color_picker(width: 100, color: INITIAL_DRAW_COLOR, channel_names: t('edit_sprite.color_picker.channel_names'))

        group do
          pack :grid, num_columns: 5, padding: 0, spacing: 4 do
            50.times do
              color_well(color: Color.rgb(rand(255), rand(255), rand(255)))
            end
          end

          subscribe :changed do |sender, value|
            @color_picker.color = value
          end
        end
      end

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

    protected
    def holding_left_mouse_button
      x, y = cursor.x, cursor.y
      if grid.hit?(x, y)
        x, y = grid.screen_to_grid(x, y)
        @image.set_pixel(x - IMAGE_X, y - IMAGE_Y, color: @color_picker.color)
      end

      nil
    end

    protected
    def holding_right_mouse_button
      x, y = cursor.x, cursor.y
      if grid.hit?(x, y)
        x, y = grid.screen_to_grid(x, y)
        @color_picker.color = Color.from_tex_play(@image.get_pixel(x - IMAGE_X, y - IMAGE_Y))
      end

      nil
    end

    public
    def update
      @@state_label.text = "Sprite: '#{@sprite.sprite.name}' [#{@sprite.sprite.id}]"
      super
    end

    public
    def draw
      grid.draw_with_respect_to do
        previous_game_state.previous_game_state.scene.draw
        flush

        draw_background
        flush

        previous_game_state.object.draw_layers
        flush

        draw_checked_background
        flush

        @image.draw(IMAGE_X, IMAGE_Y, 0)
      end

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