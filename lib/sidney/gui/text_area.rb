module Sidney
module Gui
  class TextArea < Element
    FOCUS_BORDER_COLOR = Color.rgb(0, 255, 255)
    BLUR_BORDER_COLOR = Color.rgb(255, 255, 255)
    CARET_COLOR = Color.rgb(255, 0, 0)
    SELECTION_COLOR = Color.rgb(100, 100, 100)
    CARET_PERIOD = 500 # ms

    public
    def text
      @text_input.text
    end

    public
    def text=(value)
      @text_input.text = value
      recalc
    end

    protected
    def initialize(parent, options = {})
      options = {
        text: ''
      }.merge! options

      @lines = []
      @text_positions = []
      @text_input = TextInput.new
      @text_input.text = options[:text]

      super(parent, options)
      recalc
    end

    public
    def click
      focus
    end

    public
    def focused?; @focused; end

    public
    def focus
      @focused = true
      $window.current_game_state.focus = self
      $window.text_input = @text_input
    end

    public
    def blur
      @focused = false
      $window.current_game_state.focus = nil
      $window.text_input = nil if $window.text_input == @text_input
    end

    public
    def recalc
      old_num_lines = @lines.size

      @lines.clear
      @text_positions = [[0, 0]] # Position 0 is before the first character.

      max_width = width - PADDING_X * 2
      space_width = font.text_width ' '

      line = ''
      line_width = 0
      word = ''
      word_width = 0

      position_letters_in_word = lambda {
        word.each_char do |c|
          line_width += font.text_width(c)
          @text_positions.push [line_width, @lines.size * FONT_SIZE]
        end
      }

      text.each_char do |char|
        char_width = font.text_width(char)

        overall_width = line_width + (line_width == 0 ? 0 : space_width) + word_width + char_width
        if overall_width > max_width
          if line.empty?
            # The current word is longer than the whole word, so split it.
            # Go back and set all the character positions we have.
            position_letters_in_word.call
            line_width = 0

            # Push as much of the current word as possible as a complete line.
            @lines.push word + (char == ' ' ? '' : '-')

            word = ''
            word_width = 0
          else
            # Adding the current word would be too wide, so add the current line and start a new one.
            @lines.push line
            line = ''
            line_width = 0
          end
        end

        case char
          when "\n"
            # A new-line ends the word and puts it on the line.
            line += word
            position_letters_in_word.call
            @text_positions.push [line_width, @lines.size * FONT_SIZE]
            @lines.push line
            word = ''
            word_width = 0
            line = ''
            line_width = 0

          when ' '
            # A space ends a word and puts it on the line.
            line += word + char
            position_letters_in_word.call
            line_width += space_width
            @text_positions.push [line_width, @lines.size * FONT_SIZE]

            word = ''
            word_width = 0

          else
            # If there was a previous line and we start a new line, put the caret pos on the current line.
            if line.empty?
              @text_positions.last[0..1] = [0, @lines.size * FONT_SIZE]
            end

            # Start building up a new word.
            word += char
            word_width += char_width
        end
      end

      # Add any remaining word on the last line.
      unless word.empty?
        position_letters_in_word.call
        line += word
      end

      @lines.push line if @lines.empty? or not line.empty?

      rect.height = (PADDING_Y * 2) + (FONT_SIZE * @lines.size)

      parent.recalc if @lines.size != old_num_lines and parent

      nil
    end

    public
    def draw
      recalc if focused?

      # Draw the border.
      $window.draw_box x, y, width, height, z, @focused ? FOCUS_BORDER_COLOR : BLUR_BORDER_COLOR

      caret_x, caret_y = @text_positions[@text_input.caret_pos]

      # Draw the selection.
      from = [@text_input.selection_start, @text_input.caret_pos].min
      to = [@text_input.selection_start, @text_input.caret_pos].max
      (from...to).each do |i|
        char_x, char_y = @text_positions[i]
        left, top = x + PADDING_X + char_x, y + PADDING_Y + char_y
        $window.draw_box left, top, font.text_width(text[i]), FONT_SIZE,
                       z, nil, SELECTION_COLOR
      end

      # Draw text.
      @lines.each_with_index do |line, index|
        font.draw(line, x + PADDING_X, y + PADDING_Y + FONT_SIZE * index, z)
      end

      # Draw the caret.
      if focused? and (($window.milliseconds / CARET_PERIOD) % 2 == 0)
        left, top = x + PADDING_X + caret_x, y + PADDING_Y + caret_y
        $window.draw_line left, top, CARET_COLOR, left, top + FONT_SIZE, CARET_COLOR, z
      end
    end
  end
end
end