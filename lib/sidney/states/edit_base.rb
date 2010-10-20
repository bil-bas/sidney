require_relative '../gui/selection'
require_relative 'gui_state'

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
        holding_left: -> { clear_tip; grid.left },
        holding_right: -> { clear_tip; grid.right },
        holding_up: -> { clear_tip; grid.up },
        holding_down: -> { clear_tip; grid.down },
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

      HorizontalPacker.new(container) do |packer|
        # The grid contains the actual game state.
        @grid = Grid.new(packer, ($window.height / 300).floor)

        # The zoomer allows the user to change the zoom.
        values = t 'zoom_combi.values'
        zooms = [0.5, 1, 2, 4, 8].inject({}) do |hash, value|
          hash[value] = values[value][:text]
          hash
        end

        @side_bar = VerticalPacker.new(packer) do |packer|
          @zoom_box = CombiBox.new(packer, value: INITIAL_ZOOM, tip: t('zoom_combi.tip')) do |widget|
            zooms.each_pair do |key, value|
              widget.add(key, value)
            end

            widget.subscribe :change do |widget, value|
              @grid.scale = value * @grid.base_scale
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

      GuiElement.font.draw("(#{x}, #{y})", 10, $window.height - 40, ZOrder::GUI)

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