# encoding: utf-8

require_relative 'edit_scene'

module Sidney
  # Pick a scene. Enter from editing a scene.
  class PickScene < GuiState
    def initialize
      super

      packer = pack :horizontal do
        # Picking a pack limits which scenes will be found in the scene picker.
        @pack_picker = resource_browser Pack do |sender, value|
          @scene_picker.type = value.scenes
        end

        @scene_picker = resource_browser Scene, search: 'jp', square_icons: false do |sender, value|
          if value
            @name_label.text = value.name
            @icon_label.icon = value.image
          else
            @name_label.text = ''
            @icon_label.icon = nil
          end
        end

        pack :vertical, border_color: Color.new(255, 255, 255) do
          button 'Edit Scene' do
            edit if @scene_picker.value
          end

          @name_label = label ''
          @icon_label = label '', padding: 1, border_color: Color.new(255, 255, 255)
        end
      end

      puts packer.inspect
    end

    def edit
      @edit_scene ||= EditScene.new
      @edit_scene.scene = @scene_picker.value
      push_game_state @edit_scene

      nil
    end

    def setup
      super
      #@scene_picker.refresh

      nil
    end
  end
end