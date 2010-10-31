# encoding: utf-8

require_relative 'edit_scene'

module Sidney
  # Pick a scene. Enter from editing a scene.
  class PickScene < GuiState
    def initialize
      super

      HorizontalPacker.new(container) do |packer|
        # Picking a pack limits which scenes will be found in the scene picker.
        @pack_picker = ResourceBrowser.new(packer, Pack) do |picker|
          picker.subscribe :changed do |sender, value|
            @scene_picker.type = value.scenes
          end
        end

        @scene_picker = ResourceBrowser.new(packer, Scene, search: 'jp', square_icons: false) do |picker|
          picker.subscribe :changed do |sender, value|
            if value
              @name_label.text = value.name
              @icon_label.icon = value.image
            else
              @name_label.text = ''
              @icon_label.icon = nil
            end
          end
        end

        VerticalPacker.new(packer, border_color: Color.new(255, 255, 255)) do |packer|
          Button.new(packer, text: "Edit Scene") do |button|
            button.subscribe :clicked_left_mouse_button do |sender, x, y|
              edit if @scene_picker.value
            end
          end

          @name_label = Label.new(packer)
          @icon_label = Label.new(packer, padding: 1, border_color: Color.new(255, 255, 255))
        end
      end
    end

    def edit
      @edit_scene = EditScene.new
      @edit_scene.scene = @scene_picker.value
      push_game_state @edit_scene

      nil
    end

    def setup
      @scene_picker.refresh

      nil
    end
  end
end