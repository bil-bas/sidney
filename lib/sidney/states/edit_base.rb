# encoding: utf-8

require_relative '../gui'

module Sidney
  # @abstract
  # Used as a base for editing scenes or objects (where there are sub-objects).
  class EditBase < GuiState
    include Log

    INITIAL_ZOOM = 1

    attr_reader :side_bar, :zoom_box, :grid

    protected
    def initialize
      super

      add_inputs(
        g: -> { grid.toggle_overlay if $window.holding_control? },
        holding_left: -> { clear_tip; grid.left unless focus },
        holding_right: -> { clear_tip; grid.right unless focus },
        holding_up: -> { clear_tip; grid.up unless focus },
        holding_down: -> { clear_tip; grid.down unless focus },
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

      HorizontalPacker.new(container, padding_x: 2, padding_y: 2) do |packer|
        # The grid contains the actual game state.
        @grid = Grid.new(packer, ($window.height / 300).floor)

        @side_bar = VerticalPacker.new(packer, padding_y: 0, padding_x: 0) do |packer|
          # The zoomer allows the user to change the zoom.
          values = t 'zoom_combo.values'
          zooms = [0.5, 1, 2, 4, 8].inject({}) do |hash, value|
            hash[value] = values[value][:text]
            hash
          end

          @zoom_box = ComboBox.new(packer, value: INITIAL_ZOOM, tip: t('zoom_combo.tip')) do |widget|
            zooms.each_pair do |key, value|
              widget.add(key, value)
            end

            widget.subscribe :change do |widget, value|
              @grid.scale = value * @grid.base_scale
            end
          end

          @centre_button = Button.new(packer, t('centre_button.text'),
                                        tip: t('centre_button.tip')) do |button|
            button.subscribe :click do
              @zoom_box.value = 1
              @grid.offset_x = @grid.offset_y = 0
            end
          end
        end
      end
    end

    public
    def grid_tip
      nil
    end

    public
    def update
      cursor.update
      super
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

      Element.font.draw("(#{x}, #{y})", 10, $window.height - 40, ZOrder::GUI)

      cursor.draw
      nil
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
    def cursor
      $window.cursor
    end

    protected
    def clipboard
      previous_game_state.clipboard
    end

    protected
    def history
      previous_game_state.history
    end
  end
end