# encoding: utf-8

require_relative 'edit_selectable'
require_relative 'edit_object'

module Sidney
  class EditScene < EditSelectable
    include Log

    attr_reader :clipboard, :history, :scene

    protected
    def initialize
      super

      add_inputs(
        s: ->{ save_frame if $window.holding_control? },
        f1: ->{ push_game_state GameStates::Popup.new(text: t('edit_scene.help', general: t('help'))) },
        [:return, :enter] => ->{ speak if @selection.size == 1 }
      )

      @clipboard = Clipboard.new
      @history = History.new

      @scene = Scene.load('d252be6903bd')

      TextArea.new(side_bar, width: 120, height: 300, editable: true,
              text: "T'was brillig and the Slithy toves gyred and gimbled across the wabe.\nAll mimsy were the borro1234567890goves and the mome-raths outgrabe!")

      TextArea.new(side_bar, width: 120, height: 80,
              text: "You can't edit this one.")
      TextArea.new(side_bar, width: 120, min_height: 60, max_height: 120, editable: true,
              text: "")

      nil
    end

    protected
    def speak
      speaker = @selection[0]
      speaker.toggle_speech_bubble
      nil
    end

    public
    def save_frame
      # Redraw without any selection outlines shown.
      selected_objects = @selection.to_a
      @selection.clear
      @scene.redraw
      selected_objects.each {|o| @selection.add o }

      @frame_index ||= 0
      @frame_index += 1
      flip_book_dir = File.join(ROOT_PATH, 'flip_books')
      FileUtils.mkdir_p flip_book_dir unless File.exists? flip_book_dir
      @scene.save_frame(File.join(flip_book_dir, 'frame_%05d.png' % @frame_index))

      nil
    end

    public
    def setup
      log.info { "Started editing scene" }
      nil
    end

    protected
    def edit
      @edit_object ||= EditObject.new
      @edit_object.object = @selection[0]
      push_game_state @edit_object, finalize: false

      nil
    end

    public
    def grid_tip
      if object_layer = hit_object(cursor.x, cursor.y)
        object_layer.state_object.name
      else
        nil
      end
    end

    public
    def update
      super
      @scene.reorder_layer_cache

      nil
    end

    public
    def select_all
      # TODO: Only select the items that are unlocked?
      @scene.cached_layers.each {|o| @selection.add o unless @selection.include? o }

      nil
    end

    public
    def released_right_mouse_button
      return if @selection.dragging?
      x, y = $window.mouse_x, $window.mouse_y
      if grid.hit?(x, y)
        MenuPane.new(x: x, y: y) do |widget|
          widget.add(:edit, 'Edit', shortcut: 'Ctrl-E', enabled: @selection.size == 1)
          widget.add(:mirror, 'Mirror', shortcut: 'Ctrl-M', enabled: @selection.size == 1)
          widget.add(:flip, 'Flip vertically', shortcut: 'Ctrl-N', enabled: @selection.size == 1)
          widget.add_separator
          widget.add(:copy, 'Copy', shortcut: 'Ctrl-C', enabled: (not @selection.empty?))
          widget.add(:paste, 'Paste', shortcut: 'Ctrl-V', enabled: (@selection.empty? and not @clipboard.empty?))
          widget.add(:delete, 'Delete', shortcut: 'Ctrl-X', enabled: (not @selection.empty?))

          widget.subscribe :select do |widget, value|
            case value
              when :delete then delete
              when :copy   then copy
              when :paste  then paste(x, y) # Paste at position the menu was opened, not where the mouse was just clicked.
              when :edit   then edit
              when :flip   then @selection[0].flip!
              when :mirror then @selection[0].mirror!
            end
          end

          show_menu widget
        end
      end

      nil
    end

    protected
    def delete
      copy
      @selection.each {|o| @scene.cached_layers.delete(o) }
      @selection.clear

      nil
    end

    protected
    def paste(x, y)
      return unless grid.hit?(x, y)

      # Work out the overall bounding box for the items on the clipboard.
      rects = clipboard.items.map { |o| o.rect }
      rect = rects.first.union_all(rects[1..-1])

      # Place all items from the clipboard down with the centre of the
      # bounding box at the mouse position.
      x, y = grid.screen_to_grid(x, y)
      offset_x, offset_y = (x - rect.centerx).round, (y - rect.centery).round
      @selection.clear

      clipboard.items.each do |item|
        copy = item.dup
        copy.x += offset_x
        copy.y += offset_y
        copy.selected = true
        copy.z = @scene.cached_layers.size
        @scene.cached_layers.push copy
        @selection.add copy
      end

      nil
    end

    protected
    def hit_object(x, y)
      x, y = grid.screen_to_grid(x, y)

      @scene.hit_object(x, y)
    end

    public
    def draw
      grid.draw_with_respect_to do
        @scene.draw
      end

      Element.font.draw("Scene: '#{@scene.name}' [#{@scene.id}]", 10, $window.height - 25, ZOrder::GUI)

      super
    end
  end
end