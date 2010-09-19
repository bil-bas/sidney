# encoding: utf-8

require 'gui/combi_box'
require 'gui/clipboard'
require 'gui/selection'
require 'gui/history'
require 'states/gui_state'
require 'states/edit_object'
require 'states/show_menu'

module Sidney
class EditScene < GuiState
  include Log

  attr_reader :grid, :zoom_box

  protected
  def initialize
    super

    @grid = Grid.new(($window.height / 300).floor)

    zooms = {0.5 => "50%", 1 => "100%", 2 => "200%", 4 => "400%", 8 => "800%"}
    @zoom_box = CombiBox.new(@grid.rect.right + 12, 12, 20 * @grid.scale, 8 * @grid.scale, 1)
    zooms.each_pair do |key, value|
      @zoom_box.add(key, value)
    end
    @zoom_box.on_change do |widget, value|
      @grid.scale = value * @grid.base_scale
    end

    add_element(@zoom_box)

    @font = Font.new($window, GuiElement::FONT_NAME, GuiElement::FONT_SIZE)

    add_inputs(
      g: -> { @grid.toggle_overlay if $window.holding_control? },
      holding_left: -> { @grid.left },
      holding_right: -> { @grid.right },
      holding_up: -> { @grid.up },
      holding_down: -> { @grid.down },
      s: -> { save_frame if $window.holding_control? },
      m: -> { @selection[0].mirror! if @selection.size == 1 and $window.holding_control? },
      n: -> { @selection[0].flip! if @selection.size == 1 and $window.holding_control? },
      escape: -> { @selection.reset_drag if @selection.dragging? },
      delete: -> { delete unless @selection.empty? },
      e: -> { edit_object if $window.holding_control? and @selection.size == 1 },
      x: -> { delete if $window.holding_control? and not @selection.empty? },
      c: -> { copy if $window.holding_control? and not @selection.empty? },
      v: -> { paste($window.mouse_x, $window.mouse_y) if $window.holding_control? and not @clipboard.empty? },
      f1: ->{ push_game_state Chingu::GameStates::Popup.new(text: t('edit_scene.help', general: t('help')))},
      z: lambda do
         if $window.holding_control?
           if $window.holding_shift?
             @history.redo if @history.can_redo?
           else
             @history.undo if @history.can_undo?
           end
         end
      end
    )

    @clipboard = Clipboard.new
    @history = History.new
    @selection = Selection.new

    nil
  end

  public
  def mouse_wheel_up
    @zoom_box.index += 1
    nil
  end

  public
  def mouse_wheel_down
    @zoom_box.index -= 1
    nil
  end

  public
  def save_frame
    @frame_index ||= 0
    @frame_index += 1
    @grid.save_frame(File.join(ROOT_PATH, "frame_%05d.png" % @frame_index))
  end

  public
  def setup
    log.info { "Started editing scene" }
    @grid.redraw
  end

  public
  def left_mouse_button
    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      select(x, y)

      x, y = @grid.screen_to_grid(x, y)
      @selection.begin_drag(x, y)
      @grid.redraw
    end
    
    nil
  end

  protected
  def select(x, y)
    object = @grid.hit_object(x, y)

    unless @selection.include?(object) or $window.holding_shift?
      @selection.clear
      @grid.redraw
    end

    if object
      if @selection.include? object
        if $window.holding_shift?
          @selection.remove object
          @grid.redraw
        end
      else
        @selection.add object
        @grid.redraw
      end
    end

    nil
  end

  public
  def released_left_mouse_button
    x, y = $window.cursor.x, $window.cursor.y

    @zoom_box.click(x, y)

    if @selection.dragging?
      if @grid.hit?(x, y)
        @selection.end_drag
        @grid.redraw
      else
        @selection.reset_drag
        @grid.redraw
      end
    end

    nil
  end

  public
  def right_mouse_button
    return if @selection.dragging?
    x, y = $window.cursor.x, $window.cursor.y
    select(x, y) if @grid.hit?(x, y)

    nil
  end

  public
  def holding_right_mouse_button
  end

  public
  def released_right_mouse_button
    return if @selection.dragging?
    x, y = $window.mouse_x, $window.mouse_y
    if @grid.hit?(x, y)
      MenuPane.new(x, y, ZOrder::DIALOG) do |widget|
        widget.add(:edit, 'Edit', shortcut: 'Ctrl-E', enabled: @selection.size == 1)
        widget.add(:mirror, 'Mirror', shortcut: 'Ctrl-M', enabled: @selection.size == 1)
        widget.add(:flip, 'Flip vertically', shortcut: 'Ctrl-N', enabled: @selection.size == 1)
        widget.add_separator
        widget.add(:copy, 'Copy', shortcut: 'Ctrl-C', enabled: (not @selection.empty?))
        widget.add(:paste, 'Paste', shortcut: 'Ctrl-V', enabled: (@selection.empty? and not @clipboard.empty?))
        widget.add(:delete, 'Delete', shortcut: 'Ctrl-X', enabled: (not @selection.empty?))

        widget.on_select do |widget, value|
          case value
            when :delete then delete
            when :copy   then copy
            when :paste  then paste(x, y) # Paste at position the menu was opened, not where the mouse was just clicked.
            when :edit   then edit_object
            when :flip   then @selection[0].flip!
            when :mirror then @selection[0].mirror!
          end
          @grid.redraw
        end

        push_game_state ShowMenu.new(widget)
      end
    end
    
    nil
  end

  protected
  def edit_object
    @edit_object ||= EditObject.new
    @edit_object.object = @selection[0]
    push_game_state @edit_object
    @grid.redraw
  end
  
  protected
  def delete
    copy
    @selection.each {|o| @grid.objects.delete(o) }
    @selection.clear

    @grid.redraw

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
    offset_x, offset_y = (x - rect.centerx).round, (y - rect.centery).round
    @selection.clear
    
    @clipboard.items.each do |item|
      copy = item.dup
      copy.x += offset_x
      copy.y += offset_y
      copy.selected = true
      @grid.objects.push copy
      @selection.add copy
    end

    @grid.redraw

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
    @selection.update_drag(*@grid.screen_to_grid(x, y)) if @selection.dragging?

    super
  end

  public
  def draw
    @grid.draw
    if @selection.dragging?
      $window.translate(grid.rect.x + grid.offset_x * grid.scale, grid.rect.y + grid.offset_y * grid.scale) do
        $window.scale(grid.scale) do
          @selection.each { |o| o.draw }
        end
      end
    end

    x, y = $window.cursor.x, $window.cursor.y
    if @grid.hit?(x, y)
      x, y = @grid.screen_to_grid(x, y)
      x, y = x.to_i, y.to_i
    else
      x, y = 'x', 'y'
    end

    @font.draw("(#{x}, #{y}) (#{@grid.objects.size} sprites and #{@grid.tiles.size} tiles) #{game_state_manager.current}", 0, $window.height - 25, ZOrder::GUI)
    super
  end
end
end