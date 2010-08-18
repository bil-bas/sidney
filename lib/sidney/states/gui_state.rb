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

    protected
    def initialize
      @elements = []
      @mouse_over = nil # Element the mouse is hovering over.

      super()
      add_inputs *DEFAULT_INPUTS
    end

    public
    def add_element(element)
      @elements << element
      nil
    end

    public
    def update
      x, y = $window.mouse_x, $window.mouse_y
      new_mouse_over = @elements.find { |element| element.hit? x, y }

      if new_mouse_over
        new_mouse_over.enter if new_mouse_over != @mouse_over
        new_mouse_over.hover(x, y)      
      end

      @mouse_over.leave if @mouse_over and new_mouse_over != @mouse_over

      @mouse_over = new_mouse_over

      @elements.each { |e| e.update }

      super
    end

    def draw
      @elements.each { |e| e.draw }

      nil
    end
  end
end