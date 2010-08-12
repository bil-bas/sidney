module Sidney
  class GuiState < GameState
    default_inputs = [
      :left_mouse_button, :right_mouse_button,
      :holding_left_mouse_button, :holding_right_mouse_button,
      :released_left_mouse_button, :released_right_mouse_button,
      :mouse_wheel_up, :mouse_wheel_down,
    ]

    DEFAULT_INPUTS = default_inputs.inject({}) { |hash, e| hash[e] = e; hash }

    # Will implement these later.
    default_inputs.each do |handler|
      define_method handler do
        nil
      end
    end

    protected
    def initialize
      @elements = []
      @mouse_over = nil # Element the mouse is hovering over.

      super()
    end

    protected
    def validate_input_symbol(symbol)
      raise ArgumentError, "Input must be a Symbol, but received #{symbol} (#{symbol.class})" unless symbol.is_a? Symbol

      valid = Chingu::Input::SYMBOL_TO_CONSTANT.has_key? symbol
      ["holding", "released"].each do |prefix|
        break if valid
        if symbol =~ /^#{prefix}_(.*)/
          valid = Chingu::Input::SYMBOL_TO_CONSTANT.has_key? $1.to_sym
        end
      end

      raise ArgumentError, "No such input as #{symbol.inspect}" unless valid
    end

    protected
    def validate_input_action(symbol, action)
      message = case action
        when Method, Proc, Chingu::GameState
          nil

        when String, Symbol
          "#{self.class} does not have a #{action} method" unless self.respond_to? action

        when Class
          if action.ancestors.include? Chingu::GameState
            nil
          else
            "Input action is a class (#{action.class}) not inheriting from Chingu::GameState"
          end

        else
          "Input action must be a Method, Proc, String, Symbol, Chingu::GameState or a class inheriting from Chingu::GameState (Received a #{action.class})"
      end

      raise ArgumentError, "(For input #{symbol.inspect}) #{message}" if message
    end

    public
    def input=(value)
      super(DEFAULT_INPUTS.merge(value))

      input.each_pair do |symbol, action|
        validate_input_symbol(symbol)
        validate_input_action(symbol, action)
      end

      nil
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