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
      @text_entry = TextArea.new(inner_container, width: 130, max_height: 30)
      @label = Label.new(inner_container)

      # TODO: Use a GridPacker?
      @object_list = List.new(inner_container, width: 130)

      @text_entry.subscribe :changed do |sender, text|
        @object_list.clear

        # TODO: This search should be _very_ much better...
        records = @type.all
        records.each do |record|
          if text.split(/ +/).all? {|word| record.name =~ /#{word}/i }
            @object_list.add_item(icon: Icon.new(record.thumbnail), tip: record.name, text: record.name, border_color: Color.rgb(0, 0, 0))
          end
        end
        @label.text = "#{@object_list.size} of #{records.size}"

        publish :changed, text
      end

      @text_entry.text = options['text']

    end
  end
end