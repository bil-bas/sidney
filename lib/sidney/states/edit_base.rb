require_relative '../gui/selection'
require_relative 'gui_state'

module Sidney
  # @abstract
  # Used as a base for editing scenes or objects (where there are sub-objects).
  class EditBase < GuiState
    include Log

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
      $window.flush
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
    def grid
      previous_game_state.grid
    end

    protected
    def zoom_box
      previous_game_state.zoom_box
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