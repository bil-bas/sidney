# encoding: utf-8

require_relative "resources"
require_relative "gui"

module Sidney
  class ResourceBrowser < Composite
    DEFAULT_BORDER_COLOR = Color.rgb(255, 255, 255)

    protected
    def initialize(parent, type, options = {})
      options = {
        text: '',
        border_color: DEFAULT_BORDER_COLOR.dup,
      }.merge! options

      @type = type

      super parent, VerticalPacker.new(nil), options

      # TODO: Use a side-scrolling text editor.
      @text_entry = TextArea.new(inner_container, width: 135, max_height: 30)
      @label = Label.new(inner_container)

      group = RadioButton::Group.new(inner_container)
      @object_grid = GridPacker.new(group, width: 135, num_columns: 3)

      @text_entry.subscribe :changed do |sender, text|
        @object_grid.clear

        # TODO: This search should be _very_ much better...
        records = @type.all
        records.each do |record|
          if text.split(/ +/).all? {|word| record.name =~ /#{word}/i }
            Button.new(@object_grid, icon: Icon.new(record.thumbnail), tip: record.name)
          end
        end
        @label.text = "#{@object_grid.size} of #{records.size}"

        publish :changed, text
      end

      @text_entry.text = options['text']

    end
  end
end