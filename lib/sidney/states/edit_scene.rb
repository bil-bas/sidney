# encoding: utf-8

require_relative 'edit_selectable'
require_relative 'edit_object'

module Sidney
  class EditScene < EditSelectable
    include Log

    attr_reader :clipboard, :history, :scene

    def initialize
      super

      add_inputs(
        released_escape: ->{ save_changes; pop_game_state },
        s: ->{ save_frame if $window.holding_control? },
        f1: ->{ push_game_state GameStates::Popup.new(text: t('edit_scene.help', general: t('help'))) },
        [:return, :enter] => ->{ speak if @selection.size == 1 },
        released_right_mouse_button: :released_right_mouse_button
      )

      @clipboard = Clipboard.new
      @history = History.new

      @scene = nil

      @state_bar = VerticalPacker.new(padding: 0) do
        @tint_alpha_slider = slider(width: 100, range: 0..255, tip: t('edit_scene.tint_slider.tip')) do |sender, value|
          @scene.tint.alpha = value
        end

        resource_browser StateObject
      end

      nil
    end

    def scene=(scene)
      @scene = scene
      @tint_alpha_slider.value = @scene.tint.alpha
      scene
    end

    protected
    def speak
      speaker = @selection[0]
      speaker.toggle_speech_bubble
      nil
    end

    public
    def save_changes
      # Save the current changes to the object being edited.
      @selection.clear
      @scene.save!
      @scene.redraw

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

    protected
    def edit
      @edit_object ||= EditObject.new
      @edit_object.object = @selection[0]
      push_game_state @edit_object


      nil
    end

    public
    def grid_tip
      if object_layer = hit_object(cursor.x, cursor.y)
        object_layer.state_object.name
      else
        ''
      end
    end

    public
    def update
      super
      @@state_label.text = "Scene: '#{@scene.name}' [#{@scene.id}]"
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
        menu do
          item('Edit', :edit, shortcut: 'Ctrl-E', enabled: @selection.size == 1)
          item('Mirror', :mirror, shortcut: 'Ctrl-M', enabled: @selection.size == 1)
          item('Flip', :flip, shortcut: 'Ctrl-N', enabled: @selection.size == 1)
          separator
          item('Copy', :copy, shortcut: 'Ctrl-C', enabled: (not @selection.empty?))
          item('Paste', :paste, shortcut: 'Ctrl-V', enabled: (@selection.empty? and not @clipboard.empty?))
          item('Delete', :delete, shortcut: 'Ctrl-X', enabled: (not @selection.empty?))

          subscribe :selected do |sender, value|
            case value
              when :delete then delete
              when :copy   then copy
              when :paste  then paste(x, y) # Paste at position the menu was opened, not where the mouse was just clicked.
              when :edit   then edit
              when :flip   then @selection[0].flip!
              when :mirror then @selection[0].mirror!
            end
          end
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

      super
    end
  end
end