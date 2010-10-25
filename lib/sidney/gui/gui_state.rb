# encoding: utf-8

require 'chingu'

module Sidney
  class GuiState < Chingu::GameState
    DEFAULT_INPUTS = [
      :left_mouse_button, :right_mouse_button,
      :holding_left_mouse_button, :holding_right_mouse_button,
      :released_left_mouse_button, :released_right_mouse_button,
      :mouse_wheel_up, :mouse_wheel_down,
    ]

    attr_reader :container
    attr_reader :focus

    # Will implement these later.
    private
    DEFAULT_INPUTS.each do |handler|
      define_method handler do
        nil
      end
    end

    public
    def focus=(focus)
      @focus.blur if @focus and focus
      @focus = focus
    end

    public
    def tool_tip_delay
      500 # TODO: configure this.
    end

    protected
    def initialize
      @container = Container.new(nil)

      @mouse_x, @mouse_y = 0, 0
      @focus = nil

      super()
      add_inputs *DEFAULT_INPUTS
    end

    protected
    def setup
      @mouse_over = nil # Element the mouse is hovering over.
      @mouse_moved_at = milliseconds
    end

    # Internationalisation helper.
    public
    def t(*args); I18n.t(*args); end

    public
    def update
      x, y = $window.mouse_x, $window.mouse_y

      # Maintain a record of which element we are hovering over, so we
      # can send enter/leave events.
      if @menu
        new_mouse_over = @menu if @menu.hit? x, y
      end

      new_mouse_over = @container.hit_element(x, y) unless new_mouse_over

      if new_mouse_over
        new_mouse_over.enter if new_mouse_over != @mouse_over
        new_mouse_over.hover(x, y)
      end

      @mouse_over.leave if @mouse_over and new_mouse_over != @mouse_over

      @mouse_over = new_mouse_over

      # Check if the mouse has moved, and no menu is shown, so we can show a tooltip.
      if [x, y] == [@mouse_x, @mouse_y] and (not @menu)
        if @mouse_over and (not @tool_tip) and (milliseconds - @mouse_moved_at) > tool_tip_delay
          if text = @mouse_over.tip and not text.empty?
            @tool_tip = ToolTip.new(text)
          end
        end
      else
        clear_tip
        @mouse_moved_at = milliseconds
      end

      @mouse_x, @mouse_y = x, y

      @container.update
      @menu.update if @menu
      @tool_tip.update if @tool_tip

      super
    end

    public
    def draw
      @container.draw
      @menu.draw if @menu
      @tool_tip.draw if @tool_tip

      nil
    end

    public
    def finalize
      clear_tip

      nil
    end

    # Set the menu pane to be displayed.
    #
    # @param [MenuPane] menu Menu to display.
    # @return nil
    public
    def show_menu(menu)
      hide_menu if @menu
      @menu = menu

      nil
    end

    # @return nil
    public
    def hide_menu
      @menu = nil

      nil
    end

    public
    def left_mouse_button
      # Ensure that if the user clicks away from a menu, it is automatically closed.
      if @menu
        if @mouse_over == @menu
          return :handled
        else
          hide_menu
        end
      end

      if @focus and @mouse_over != @focus
        @focus.blur
        @focus = nil
      end

      nil
    end

    public
    def released_left_mouse_button
      # Ensure that if the user clicks away from a menu, it is automatically closed.
      if @menu and @mouse_over != @menu
        hide_menu
      end

      @mouse_over.publish :click if @mouse_over

      nil
    end

    # Hide the tool-tip, if any.
    protected
    def clear_tip
      @tool_tip = nil
      @mouse_moved_at = milliseconds

      nil
    end

    public
    def flush
      $window.flush
    end
  end
end