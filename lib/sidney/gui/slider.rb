# encoding: utf-8

require_relative 'container'

module Sidney
module Gui
  class Slider < Container
    # @private
    class Handle < Element
      BACKGROUND_COLOR = Color.rgb(255, 0, 0)

      protected
      def initialize(parent, options = {}, &block)
        super parent, options
      end

      public
      def draw
        $window.draw_box x, y, width, height, z, nil, BACKGROUND_COLOR
        super
      end
    end

    BACKGROUND_COLOR = Color.rgb(200, 200, 200)

    attr_reader :value, :range

    # @param [Range] range (0..1.0)
    # @param [Range] value (0)
    protected
    def initialize(parent, options = {}, &block)
      options = {
        range: 0..1.0,
        value: 0,
        height: 25
      }.merge! options

      @range = options[:range]

      super(parent, options)

      @handle = Handle.new(self, width: (height / 2 - padding_x), height: height - padding_y * 2)
      self.value = options[:value]
    end

    protected
    def layout
      nil
    end

    public
    def value=(value)
      raise ArgumentError, "value (#{value}} must be within range #{@range}" unless @range.include? value
      @value = value
      @handle.x = x + padding_x + ((width - padding_x * 2) * ((value - @range.min) / (@range.max - @range.min).to_f) - @handle.width / 2).round
      publish :changed, value

      @value
    end

    public
    def tip
      "#{super}: #{@value}"
    end

    public
    def draw
      $window.draw_box x + padding_x, y + padding_y, width - padding_x * 2, height - padding_y * 4, z, nil, BACKGROUND_COLOR
      super
    end

    public
    def left_mouse_button(sender, x, y)
      value = (((x - self.x - padding_x) / (width - padding_x * 2)) * (@range.max - @range.min) + @range.min).to_i
      self.value = [[value, @range.max].min, @range.min].max
      @mouse_down = true

      nil
    end

    public
    def hit_element(x, y)
      if @handle.hit?(x, y)
        self # TODO: should pass this to the handle, so it can be dragged.
      elsif hit?(x, y)
        self
      else
        nil
      end
    end
  end
end
end