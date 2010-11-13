# encoding: utf-8

require_relative '../resource_browser'

module Sidney
  # @abstract
  # Used as a base for editing scenes or objects (where there are sub-objects).
  class EditBase < GuiState
    include Log

    INITIAL_ZOOM = 1
    BACKGROUND_COLOR = Color.rgba(0, 0, 0, 175)

    attr_reader :state_bar

    public
    def state_bar_container
      @@state_bar_container
    end

    public
    def zoom_box
      @@zoom_box
    end

    public
    def grid
      @@grid
    end

    protected
    def initialize
      super

      add_inputs(
        g: -> { grid.toggle_overlay if $window.holding_control? },
        holding_left: -> { clear_tip; grid.left unless focus },
        holding_right: -> { clear_tip; grid.right unless focus },
        holding_up: -> { clear_tip; grid.up unless focus },
        holding_down: -> { clear_tip; grid.down unless focus },
        mouse_wheel_up: :mouse_wheel_up,
        mouse_wheel_down: :mouse_wheel_down,
        m: -> { @selection[0].mirror! if @selection.size == 1 and $window.holding_control? },
        n: -> { @selection[0].flip! if @selection.size == 1 and $window.holding_control? },
        z: lambda do
           if $window.holding_control?
             if $window.holding_shift?
               history.redo if history.can_redo?
             else
               history.undo if history.can_undo?
             end
           end
        end
      )

      # Create a common packer, used by all editing modes.
      @@edit_packer ||= HorizontalPacker.new(padding: 2) do
        pack :vertical, padding: 0 do |packer|
          # The grid contains the actual game state.
          @@grid = Grid.new(($window.height / 300).floor, parent: packer)

          @@base_packer = pack :vertical do
            @@coordinate_label = label ''
            @@state_label = label ''
          end
        end

        pack :vertical, padding: 0 do
          # The zoomer allows the user to change the zoom.
          values = t 'zoom_combo.values'
          zooms = [0.5, 1, 2, 4, 8].inject({}) do |hash, value|
            hash[value] = values[value][:text]
            hash
          end

          pack :horizontal, padding: 0 do
            @@zoom_box = combo_box(value: INITIAL_ZOOM, tip: t('zoom_combo.tip')) do
              zooms.each_pair do |key, text|
                item(text, key)
              end

              subscribe :changed do |widget, value|
                @@grid.scale = value * @@grid.base_scale
              end
            end

            @@centre_button = button('', icon: Image['center.png'], tip: t('centre_button.tip')) do
              @@zoom_box.value = 1
              @@grid.offset_x = @@grid.offset_y = 0
            end

            @@grid_button = toggle_button('', value: true, icon: Image['grid.png'],
                                          on_tip: t('grid_button.on.tip'), off_tip: t('grid_button.off.tip')) do
              @@grid.toggle_overlay
            end
          end

          # Sidebar used by the individual states.
          @@state_bar_container = pack :vertical, padding: 0
        end
      end
    end

    public
    def grid_tip
      nil
    end

    public
    def draw
      super
      flush

      x, y = cursor.x, cursor.y
      if grid.hit?(x, y)
        x, y = grid.screen_to_grid(x, y)
        x, y = x.to_i, y.to_i
      else
        x, y = 'x', 'y'
      end

      @@coordinate_label.text = "(#{x}, #{y})"
      nil
    end

    public
    def setup
      super
      log.info { "Entered state" }

      # Move the layout into the window, then add state-specific elements.
      container.add @@edit_packer
      state_bar_container.add state_bar

      super
    end

    public
    def finalize
      super
      log.info { "Left state" }

      # Move the layout out of the window, then remove state-specific elements.
      container.remove @@edit_packer
      state_bar_container.remove state_bar

      super
    end

    public
    def mouse_wheel_up
      zoom_box.index += 1
      nil
    end

    public
    def mouse_wheel_down
      zoom_box.index -= 1
      nil
    end

    protected
    def clipboard
      previous_game_state.clipboard
    end

    protected
    def history
      previous_game_state.history
    end

    protected
    def draw_checked_background
      unless defined? @@transparent_large
        row = [[80, 80, 80, 255], [120, 120, 120, 255]]
        blob = [row, row.reverse]
        # Small transparent checkerboard drawn behind colour wells.
        transparent_small = Image.from_blob(blob.flatten.pack('C*'), 2, 2, caching: true)
        # Large grey checkerboard drawn behind the sprite being edited.
        @@transparent_large = Image.create(Grid::WIDTH + Grid::CELL_WIDTH, Grid::HEIGHT + Grid::CELL_HEIGHT)
        @@transparent_large.rect 0, 0, @@transparent_large.width - 1, @@transparent_large.height - 1,
                                fill: true, texture: transparent_small
      end

      @@transparent_large.draw(((grid.offset_x % Grid::CELL_WIDTH) - Grid::CELL_WIDTH - grid.offset_x),
                               ((grid.offset_y % Grid::CELL_HEIGHT) - Grid::CELL_HEIGHT - grid.offset_y),
                               0, 8.0 / grid.scale, 8.0 / grid.scale, Color.rgba(255, 255, 255, 100))

      nil
    end

    protected
    def draw_background
      draw_rect -grid.width, -grid.height, grid.width * 2, grid.height * 2, 0, BACKGROUND_COLOR
      nil
    end
  end
end