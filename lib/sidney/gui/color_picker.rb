# encoding: utf-8

require_relative 'vertical_packer'

module Sidney
module Gui
  class ColorPicker < VerticalPacker
    DEFAULT_COLOR = Color.rgba(255, 255, 255, 255)
    CHANNELS = [:red, :green, :blue, :alpha]
    DEFAULT_CHANNEL_NAMES = CHANNELS.map {|c| c.to_s.capitalize }

    INDICATOR_HEIGHT = 20

    public
    def color; @color.dup; end

    def color=(value)
      @color = value.dup
      CHANNELS.each do |channel|
        @sliders[channel].value = @color.send channel
      end

      publish :changed, @color.dup
    end

    protected
    def initialize(parent, options = {}, &block)
      options = {
        padding: 0,
        spacing: 0,
        channel_names: DEFAULT_CHANNEL_NAMES
      }.merge! options

      @color = options[:color] || DEFAULT_COLOR.dup

      super(parent, options)

      @sliders = {}
      CHANNELS.each_with_index do |channel, i|
        Slider.new(self, value: @color.send(channel), range: 0..255, width: width, tip: options[:channel_names][i]) do |slider|
          slider.subscribe :changed do |sender, value|
            @color.send "#{channel}=", value
          end

          @sliders[channel] = slider
        end
      end

      unless defined? @@color_picker_transparent
        row = [[80, 80, 80, 255], [120, 120, 120, 255]]
        blob = [row, row.reverse]
        @@color_picker_transparent = Image.from_blob(blob.flatten.pack('C*'), 2, 2, caching: true)
      end
    end

    protected
    def layout
      super
      rect.height += INDICATOR_HEIGHT
    end

    public
    def draw
      sliders_height = @sliders[:red].height * 4

      @@color_picker_transparent.draw x, y + sliders_height, z, width / 2, INDICATOR_HEIGHT / 2

      $window.draw_box x, y + sliders_height, width, INDICATOR_HEIGHT, z, nil, @color

      super
    end
  end
end
end