require 'gui/combi_box'
require 'clipboard'
require 'history'

class EditScene < GameState
  def initialize
    super

    @grid = Grid.new(($window.height / 240).floor)

    zooms = {0.5 => "50%", 1 => "100%", 2 => "200%", 4 => "400%", 8 => "800%"}
    @zoom_box = CombiBox.new(@grid.rect.right + 12, 12, 20 * @grid.scale, 8 * @grid.scale, 1)
    zooms.each_pair do |key, value|
      @zoom_box.add(key, value)
    end
    @zoom_box.on_change do |widget, value|
      @grid.scale = value * @grid.base_scale
    end

    @font = Font.new($window, nil, 14)

    self.input = {
      :left_mouse_button => :left_mouse_button,
      :released_left_mouse_button => :released_left_mouse_button,
      :holding_left_mouse_button => :holding_left_mouse_button,
      :right_mouse_button => :right_mouse_button,
      :released_right_mouse_button => :released_right_mouse_button,
      :holding_right_mouse_button => :holding_right_mouse_button,
      :g => lambda { @grid.toggle_overlay },
      :wheel_up => lambda { @zoom_box.index += 1 },
      :wheel_down => lambda { @zoom_box.index -= 1 },
      :holding_left => lambda { @grid.left },
      :holding_right => lambda { @grid.right },
      :holding_up => lambda { @grid.up },
      :holding_down => lambda { @grid.down },
      :z => lambda {
         if $window.button_down?(Button::KbLeftControl) or $window.button_down?(Button::KbRightControl)
           if $window.button_down?(Button::KbLeftShift) or $window.button_down?(Button::KbRightShift)
             @history.redo if @history.can_redo?
           else
             @history.undo if @history.can_undo?
           end
         end
      },
    }

    @clipboard = Clipboard.new
    @context_menu = nil
    @history = History.new

    @selection = Array.new

    nil
  end

  def left_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    select(x, y) if not @context_menu and @grid.hit?(x, y)
    
    nil
  end

  def select(x, y)    
    x, y = @grid.screen_to_grid(x, y)
    if object = @grid.hit_object(x, y)
      unless @selection.include? object
        @selection.push object
        object.selected = true
      end
    else
      @selection.each { |o| o.selected = false }
      @selection.clear
    end

    nil
  end

  def released_left_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    
    if @context_menu
      if @context_menu.hit?(x, y)
        @context_menu.click(x, y)
      else
        @zoom_box.click(x, y)
        select(x, y) if @grid.hit?(x, y)
      end
      @context_menu = nil
    else
      @zoom_box.click(x, y)
      select(x, y) if @grid.hit?(x, y)
    end

    nil
  end

  def holding_left_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      x, y = @grid.screen_to_grid(x, y)
      if object = @grid.hit_object(x, y)
        object.set_screen_pixel(x, y, :red)
      end
    end

    nil
  end

  def right_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    select(x, y) if not @context_menu and @grid.hit?(x, y)
    
    nil
  end

  def released_right_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      select(x, y) unless @context_menu
      @context_menu = MenuPane.new($window.mouse_x, $window.mouse_y, ZOrder::DIALOG) do |widget|
        widget.add(:edit, 'Edit', :enabled => @selection.size == 1)
        widget.add_separator
        widget.add(:copy, 'Copy', :shortcut => 'Ctrl-C', :enabled => (not @selection.empty?))
        widget.add(:paste, 'Paste', :shortcut => 'Ctrl-V', :enabled => (@selection.empty? and not @clipboard.empty?))
        widget.add(:delete, 'Delete', :shortcut => 'Ctrl-X', :enabled => (not @selection.empty?))

        widget.on_select do |widget, value|
          case value
            when :delete
               delete(x, y)

            when :copy
               copy(x, y)

            when :paste
               paste(x, y)

            else
              p "#{value} #{@selection.size}"

          end
        end
      end
    end
    
    nil
  end

  protected
  def delete(x, y)
    copy(x, y)    
    @selection.each {|o| @grid.objects.delete(o) }
    @selection.clear

    nil
  end

  protected
  def paste(x, y)
    x, y = @grid.screen_to_grid(x, y)
    offset_x, offset_y = x - @clipboard.x, y - @clipboard.y
    @selection = @clipboard.items.map do |item|
      copy = item.dup
      copy.x += offset_x
      copy.y += offset_y
      copy.selected = true
      @grid.objects.push copy
      copy
    end

    nil
  end

  protected
  def copy(x, y)
    x, y = @grid.screen_to_grid(x, y)
    @clipboard.copy(@selection, x, y)

    nil
  end

  public
  def holding_right_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      x, y = @grid.screen_to_grid(x, y)
      if object = @grid.hit_object(x, y)
        object.set_screen_pixel(x, y, :blue)
      end
    end

    nil
  end

  def update
    @grid.update
    x, y = $window.cursor.x, $window.cursor.y
    @zoom_box.hit?(x, y)
    @context_menu.hit?(x, y) if @context_menu

    super
  end

  def draw
    @grid.draw
    @zoom_box.draw
    @context_menu.draw if @context_menu

    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      x, y = @grid.screen_to_grid(x, y)
      x, y = x.to_i, y.to_i
    else
      x, y = 'x', 'y'
    end
    @font.draw("(#{x}, #{y})", 0, 650, ZOrder::GUI)
    
    super
  end
=begin
  # Called Each time when we enter the game state, use this to reset the gamestate to a "virgin state"
  def setup
  end

  # Called when we leave the game state
  def finalize
  end
=end
end