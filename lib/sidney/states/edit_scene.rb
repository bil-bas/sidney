require 'gui/combi_box'
require 'gui/clipboard'
require 'gui/selection'
require 'gui/dragger'
require 'gui/history'
require 'states/edit_object'
require 'states/show_menu'

class EditScene < GameState
  attr_reader :grid

  protected
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
      :escape => lambda { @dragger.reset if @dragger.active? },
      :delete => lambda { delete unless @selection.empty? },
      :x => lambda { delete if $window.control_down? and not @selection.empty? },
      :c => lambda { copy if $window.control_down? and not @selection.empty? },
      :v => lambda { paste($window.mouse_x, $window.mouse_y) if $window.control_down? and not @clipboard.empty? },
      :z => lambda {
         if $window.control_down?
           if $window.shift_down?
             @history.redo if @history.can_redo?
           else
             @history.undo if @history.can_undo?
           end
         end
      },
    }

    @clipboard = Clipboard.new
    @history = History.new
    @selection = Selection.new
    @dragger = Dragger.new

    nil
  end

  public
  def left_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    select(x, y) if @grid.hit?(x, y)
    
    nil
  end

  protected
  def select(x, y)    
    x, y = @grid.screen_to_grid(x, y)

    object = @grid.hit_object(x, y)

    unless @selection.include?(object) or $window.shift_down?
      @selection.clear
    end

    if object
      if @selection.include? object
        @selection.remove object if $window.shift_down?
      else
        @selection.add object
      end
    end

    nil
  end

  public
  def released_left_mouse_button
    x, y = $window.cursor.x, $window.cursor.y

    @zoom_box.click(x, y)

    @dragger.end unless @dragger.empty?

    nil
  end

  public
  def holding_left_mouse_button
    if not @selection.empty? and @dragger.empty?
      x, y = @grid.screen_to_grid($window.cursor.x, $window.cursor.y)
      @dragger.begin(@selection, x, y)
    end
  end

  public
  def right_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    select(x, y) if @grid.hit?(x, y)

    nil
  end

  public
  def holding_right_mouse_button
  end

  public
  def released_right_mouse_button
    x, y = $window.mouse_x, $window.mouse_y
    if @grid.hit?(x, y)
      MenuPane.new(x, y, ZOrder::DIALOG) do |widget|
        widget.add(:edit, 'Edit', :enabled => @selection.size == 1)
        widget.add_separator
        widget.add(:copy, 'Copy', :shortcut => 'Ctrl-C', :enabled => (not @selection.empty?))
        widget.add(:paste, 'Paste', :shortcut => 'Ctrl-V', :enabled => (@selection.empty? and not @clipboard.empty?))
        widget.add(:delete, 'Delete', :shortcut => 'Ctrl-X', :enabled => (not @selection.empty?))

        widget.on_select do |widget, value|
          case value
            when :delete
              delete

            when :copy
              copy

            when :paste
              paste(x, y) # Paste at position the menu was opened, not where the mouse was just clicked.

            when :edit
              game_state_manager.push EditObject.new(@selection[0])

          end
        end

        game_state_manager.push ShowMenu.new(widget)
      end
    end

    @dragger.end unless @dragger.empty?
    
    nil
  end

  protected
  def delete
    copy
    @selection.each {|o| @grid.objects.delete(o) }
    @selection.clear

    nil
  end

  protected
  def paste(x, y)
    # Work out the overall bounding box for the items on the clipboard.
    rects = @clipboard.items.map { |o| o.rect }
    rect = rects.first.union_all(rects[1..-1])

    # Place all items from the clipboard down with the centre of the
    # bounding box at the mouse position.
    x, y = @grid.screen_to_grid(x, y)
    offset_x, offset_y = x - rect.centerx, y - rect.centery
    @selection.clear
    
    @clipboard.items.each do |item|
      copy = item.dup
      copy.x += offset_x
      copy.y += offset_y
      copy.selected = true
      @grid.objects.push copy
      @selection.add copy
    end

    nil
  end

  protected
  def copy
    @clipboard.copy(@selection)

    nil
  end

  public
  def update
    @grid.update
    x, y = $window.cursor.x, $window.cursor.y
    @zoom_box.hit?(x, y)
    @dragger.update(*@grid.screen_to_grid(x, y)) unless @dragger.empty?

    super
  end

  public
  def draw
    @grid.draw
    @zoom_box.draw

    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      x, y = @grid.screen_to_grid(x, y)
      x, y = x.to_i, y.to_i
    else
      x, y = 'x', 'y'
    end

    @font.draw("(#{x}, #{y}) (#{@grid.objects.size} sprites and #{@grid.tiles.size} tiles) #{game_state_manager.current}", 0, 650, ZOrder::GUI)
    
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