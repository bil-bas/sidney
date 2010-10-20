require_relative '../gui/combi_box'
require_relative '../gui/selection'

require_relative 'edit_base'

module Sidney
  # @abstract
  # Used as a base for editing scenes or objects (where there are sub-objects).
  class EditSelectable < EditBase
    include Log

    protected
    def initialize
      super

      @selection = Selection.new

      add_inputs(
        a: -> { select_all if $window.holding_control? },
        escape: -> { @selection.reset_drag if @selection.dragging? },
        delete: -> { delete unless @selection.empty? },
        e: -> { edit if $window.holding_control? and @selection.size == 1 },
        x: -> { delete if $window.holding_control? and not @selection.empty? },
        c: -> { copy if $window.holding_control? and not @selection.empty? },
        v: -> { paste($window.mouse_x, $window.mouse_y) if $window.holding_control? and not clipboard.empty? }
      )

      nil
    end

    public
    def left_mouse_button
      return if super == :handled

      x, y = cursor.x, cursor.y
      if grid.hit?(x, y)
        select(x, y)

        unless @selection.empty?
          x, y = grid.screen_to_grid(x, y)
          @selection.begin_drag(x, y)
        end
      end

      nil
    end

    public
    def released_left_mouse_button
      super

      x, y = cursor.x, cursor.y

      if @selection.dragging?
        if grid.hit?(x, y)
          @selection.end_drag
        else
          @selection.reset_drag
        end
      end

      nil
    end

    protected
    def select(x, y)
      object = hit_object(x, y)

      unless @selection.include?(object) or $window.holding_shift?
        @selection.clear
      end

      if object
        if @selection.include? object
          if $window.holding_shift?
            @selection.remove object
          end
        else
          @selection.add object
        end
      end

      nil
    end

    public
    def right_mouse_button
      return if @selection.dragging?
      x, y = cursor.x, cursor.y
      select(x, y) if grid.hit?(x, y)

      nil
    end

    protected
    def copy
      clipboard.copy(@selection)

      nil
    end

    public
    def update
      x, y = cursor.x, cursor.y
      @selection.update_drag(*grid.screen_to_grid(x, y)) if @selection.dragging?

      super
    end
  end
end