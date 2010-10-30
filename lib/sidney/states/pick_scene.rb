# encoding: utf-8

require_relative 'edit_scene'

module Sidney
  # Pick a scene. Enter from editing a scene.
  class PickScene < GuiState
    def initialize
      super

      HorizontalPacker.new(container) do |packer|
        @scene_picker = ResourceBrowser.new(packer, Scene, search: 'jp')
        Button.new(packer, text: "Edit Scene") do |button|
          button.subscribe :clicked_left_mouse_button do |sender, x, y|
            edit if @scene_picker.value
          end
        end

        Label.new(container)
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