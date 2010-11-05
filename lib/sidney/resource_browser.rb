# encoding: utf-8

require_relative "resources"


module Fidgit
  class Container
    def resource_browser(type, options = {}, &block)
      Sidney::ResourceBrowser.new(self, type, options, &block)
    end
  end
end

module Sidney
  class ResourceBrowser < Composite
    DEFAULT_BORDER_COLOR = Color.rgb(255, 255, 255)

    handles :changed

    def value; @group.value; end
    def search; @text_entry.text; end
    def type; @type; end

    def type=(type)
      @type = type
      refresh
      type
    end

    def search=(search)
      @text_entry.text = search
      search
    end

    def refresh
      selected_resource = @group.value
      recreate_group

      # TODO: This search should be _very_ much better...
      resources = @type.all
      resources.each do |resource|
        if self.search.split(/ +/).all? {|word| resource.name =~ /#{word}/i }
          icon = resource.thumbnail
          icon = Thumbnail.new(icon) if @square_icons
          @object_grid.radio_button resource, icon: icon, tip: resource.name
        end
      end
      @label.text = "#{@object_grid.size} found from #{resources.size}"

      # See if the previously selected resource is still in the list and if so, select it again.
      if resources.find {|r| r == selected_resource }
        @group.value = selected_resource
      else
        publish :changed, nil
      end

      nil
    end

    def initialize(parent, type, options = {})
      options = {
        square_icons: true,
        search: '',
        border_color: DEFAULT_BORDER_COLOR.dup,
      }.merge! options

      @square_icons = options[:square_icons]

      super parent, options
      @type = type

      @packer = pack :vertical do
        # TODO: Use a side-scrolling text editor.
        @text_entry = text_area(width: 135, max_height: 30) do
          refresh
        end

        @label = label ''
        @group = group
      end

      self.search = options[:search] # This will create the group and new radios.
    end

    def recreate_group
      @packer.remove @group

      @group = @packer.group do
        subscribe :changed do |sender, value|
          publish :changed, value
        end

        @object_grid = pack :grid, width: 135, num_columns: 3
      end

      nil
    end

    protected
    def post_init_block(&block)
      subscribe :changed, &block
    end
  end
end