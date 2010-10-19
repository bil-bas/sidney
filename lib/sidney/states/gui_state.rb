require_relative "../gui/tool_tip"

module Sidney
  class GuiState < GameState
    DEFAULT_INPUTS = [
      :left_mouse_button, :right_mouse_button,
      :holding_left_mouse_button, :holding_right_mouse_button,
      :released_left_mouse_button, :released_right_mouse_button,
      :mouse_wheel_up, :mouse_wheel_down,
    ]

    # Will implement these later.
    private
    DEFAULT_INPUTS.each do |handler|
      define_method handler do
        nil
      end
    end

    def tool_tip_delay
      0.5 # TODO: configure this.
    end

    protected
    def initialize
      @elements = []
      @mouse_over = nil # Element the mouse is hovering over.
      @mouse_moved_at = Time.now
      @mouse_x, @mouse_y = 0, 0

      super()
      add_inputs *DEFAULT_INPUTS
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
      new_mouse_over = @elements.find { |element| element.hit? x, y }

      if new_mouse_over
        new_mouse_over.enter if new_mouse_over != @mouse_over
        new_mouse_over.hover(x, y)
      end

      @mouse_over.leave if @mouse_over and new_mouse_over != @mouse_over

      @mouse_over = new_mouse_over

      # Check if the mouse has moved, so we can show a tooltip.
      if [x, y] == [@mouse_x, @mouse_y]
        if @mouse_over and not @tool_tip and Time.now - @mouse_moved_at > tool_tip_delay
          if text = @mouse_over.tip and not text.empty?
            @tool_tip = ToolTip.new(text)
            add_element @tool_tip
          end
        end
      else
        clear_tip
        @mouse_x, @mouse_y = x, y
        @mouse_moved_at = Time.now
      end

      @elements.each { |e| e.update }

      super
    end

    def draw
      @elements.each { |e| e.draw }

      nil
    end

    public
    def finalize
      clear_tip
    end

    # Hide the tool-tip, if any.
    protected
    def clear_tip
      remove_element @tool_tip if @tool_tip
      @tool_tip = nil
    end
  end
end