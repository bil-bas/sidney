require_relative 'container'

module Sidney
module Gui
  # A vertically aligned element packing container.
  class VerticalPacker < Container
    protected
    def initialize(options = {}, &block)
      super
      post_init &block
    end

    public
    def recalc
      rect.width = (@children.map {|c| c.width }.max || 0) + (padding_x * 2)

      rect.height = @children.inject(0) {|total, c| total + c.height } +
                 (padding_y * 2) + (spacing_y * [@children.size - 1, 0].max)

      super
    end

    public
    def add(element)
      element.x = x + padding_x
      element.y = y + height - padding_y + spacing_y

      super
    end
  end
end
end