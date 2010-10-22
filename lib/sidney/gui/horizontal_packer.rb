# encoding: utf-8

require_relative 'container'

module Sidney
module Gui
  # A vertically aligned element packing container.
  class HorizontalPacker < Container
    protected
    def initialize(options = {}, &block)
      super
      post_init &block
    end

    public
    def recalc
      rect.width = @children.inject(0) {|total, c| total + c.width } +
                 (padding_x * 2) + (spacing_x * [@children.size - 1, 0].max)

      rect.height = (@children.map {|c| c.height }.max || 0) + (padding_y * 2)

      super
    end

    public
    def add(element)
      element.x = x + width - padding_x + spacing_x
      element.y = y + padding_y

      super
    end
  end
end
end