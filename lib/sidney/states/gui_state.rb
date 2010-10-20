require_relative "../gui/tool_tip"

module Sidney
  class GuiState < GameState
    DEFAULT_INPUTS = [
      :left_mouse_button, :right_mouse_button,
      :holding_left_mouse_button, :holding_right_mouse_button,
      :released_left_mouse_button, :released_right_mouse_button,
      :mouse_wheel_up, :mouse_wheel_down,
    ]

    attr_reader :elements

    # Will implement these later.
    private
    DEFAULT_INPUTS.each do |handler|
      define_method handler do
        nil
      end
    end

    public
    def tool_tip_delay
      0.5 # TODO: configure this.
    end

    protected
    def initialize
      @elements = []
      @mouse_x, @mouse_y = 0, 0

      super()
      add_inputs *DEFAULT_INPUTS
    end

    protected
    def setup
      @mouse_over = nil # Element the mouse is hovering over.
      @mouse_moved_at = Time.now
    end

    public
    def add_element(element)
      @elements << element
      nil
    end

    public
    def remove_element(element)
      @elements.delete element
      nil
    end

    # Internationalisation helper.
    public
    def t(*args); I18n.t(*args); end

    public
    def update
      x, y = $window.mouse_x, $window.mouse_y

      # Maintain a record of which element we are hovering over, so we
      # can send enter/leave events.
      new_mouse_over = @elements.reverse.find { |element| element.hit? x, y }

      if new_mouse_over
        new_mouse_over.enter if new_mouse_over != @mouse_over
        new_mouse_over.hover(x, y)
      end

      @mouse_over.leave if @mouse_over and new_mouse_over != @mouse_over

      @mouse_over = new_mouse_over

      # Check if the mouse has moved, and no menu is shown, so we can show a tooltip.
      if [x, y] == [@mouse_x, @mouse_y] and (not @menu)
        if @mouse_over and (not @tool_tip) and (Time.now - @mouse_moved_at) > tool_tip_delay
          if text = @mouse_over.tip and not text.empty?
            @tool_tip = ToolTip.new(text)
            add_element @tool_tip
          end
        end
      else
        clear_tip
        @mouse_moved_at = Time.now
      end

      @mouse_x, @mouse_y = x, y

      @elements.each { |e| e.update }

      super
    end

    public
    def draw
      @elements.each { |e| e.draw }

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
      add_element menu

      nil
    end

    # @return [MenuPane, nil] Menu that was hidden, if any.
    public
    def hide_menu
      remove_element @menu
      menu = @menu
      @menu = nil

      menu
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

      nil
    end

    public
    def released_left_mouse_button
      # Ensure that if the user clicks away from a menu, it is automatically closed.
      if @menu and @mouse_over != @menu
        hide_menu
      end

      @mouse_over.click if @mouse_over

      nil
    end

    # Hide the tool-tip, if any.
    protected
    def clear_tip
      remove_element @tool_tip if @tool_tip
      @tool_tip = nil
      @mouse_moved_at = Time.now

      nil
    end
  end
end