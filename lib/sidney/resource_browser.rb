# encoding: utf-8

require_relative "resources"

module Sidney
  class ResourceBrowser < Composite
    DEFAULT_BORDER_COLOR = Color.rgb(255, 255, 255)

    attr_reader :value

    def refresh
      refresh_group

      selected_resource = @value

      # TODO: This search should be _very_ much better...
      resources = @type.all
      resources.each do |resource|
        if @text_entry.text.split(/ +/).all? {|word| resource.name =~ /#{word}/i }
          icon = resource.thumbnail
          icon = Thumbnail.new(icon) if @square_icons
          RadioButton.new(@object_grid, resource, icon: icon, tip: resource.name)
        end
      end
      @label.text = "#{@object_grid.size} found from #{resources.size}"

      if resources.find {|r| r == selected_resource }
        @group.value = selected_resource
      else
        publish :changed, @value
      end

      nil
    end

    def initialize(parent, type, options = {})
      options = {
        square_icons: true,
        search: '',
        border_color: DEFAULT_BORDER_COLOR.dup,
      }.merge! options

      @type = type
      @square_icons = options[:square_icons]

      super parent, VerticalPacker.new(nil), options

      # TODO: Use a side-scrolling text editor.
      @text_entry = TextArea.new(inner_container, width: 135, max_height: 30)
      @text_entry.subscribe :changed do
        refresh
      end

      @label = Label.new(inner_container)

      @text_entry.text = options[:search] # This will create the group and new radios.
    end

    protected
    def refresh_group
      inner_container.remove @group if @group

      @group = RadioButton::Group.new(inner_container) do |group|
        @object_grid = GridPacker.new(group, width: 135, num_columns: 3)
        group.subscribe :changed do |sender, value|
          @value = value
          publish :changed, value
        end
      end

      nil
    end
  end
end