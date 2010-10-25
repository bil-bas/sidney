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
      @focus.publish :blur if @focus and focus
      @focus = focus
    end

    public
    def tool_tip_delay
      500 # TODO: configure this.
    end

    protected
    def initialize
      @outer_container = Container.new(nil) do |container|
        @container = Container.new(container)
      end

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

      new_mouse_over = @outer_container.hit_element(x, y)

      if new_mouse_over
        new_mouse_over.publish :enter if new_mouse_over != @mouse_over
        new_mouse_over.publish :hover, x, y
      end

      @mouse_over.publish :leave if @mouse_over and new_mouse_over != @mouse_over

      @mouse_over = new_mouse_over

      # Check if the mouse has moved, and no menu is shown, so we can show a tooltip.
      if [x, y] == [@mouse_x, @mouse_y] and (not @menu)
        if @mouse_over and (not @tool_tip) and (milliseconds - @mouse_moved_at) > tool_tip_delay
          if text = @mouse_over.tip and not text.empty?
            @tool_tip = ToolTip.new(text)
            @outer_container.add @tool_tip
          end
        end
      else
        clear_tip
        @mouse_moved_at = milliseconds
      end

      @mouse_x, @mouse_y = x, y

      @outer_container.update

      super
    end

    public
    def draw
      @outer_container.draw

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
      @outer_container.add @menu

      nil
    end

    # @return nil
    public
    def hide_menu
      @outer_container.remove @menu if @menu
      @menu = nil

      nil
    end

    public
    def left_mouse_button
      # Ensure that if the user clicks away from a menu, it is automatically closed.
      hide_menu unless @menu and @menu == @mouse_over

      if @focus and @mouse_over != @focus
        @focus.publish :blur
        @focus = nil
      end

      if @mouse_over
        @mouse_over.publish :left_mouse_button, @mouse_x, @mouse_y
        @mouse_down_on = @mouse_over
      else
        @mouse_down_on = nil
      end

      nil
    end

    public
    def released_left_mouse_button
      # Ensure that if the user clicks away from a menu, it is automatically closed.
      hide_menu if @menu and @mouse_over != @menu

      if @mouse_over
        @mouse_over.publish :released_left_mouse_button, @mouse_x, @mouse_y
        @mouse_over.publish :clicked_left_mouse_button, @mouse_x, @mouse_y if @mouse_over == @mouse_down_on
      end

      nil
    end

    # Hide the tool-tip, if any.
    protected
    def clear_tip
      @outer_container.remove @tool_tip if @tool_tip
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