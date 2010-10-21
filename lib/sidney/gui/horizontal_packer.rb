require_relative 'container'

module Sidney
module Gui
  # A vertically aligned element packing container.
  class HorizontalPacker < Container
    public
    def recalc
      rect.width = @children.inject(0) {|total, c| total + c.width } +
                 (PADDING_X * 2) + (SPACING_X * [@children.size - 1, 0].max)

      rect.height = (@children.map {|c| c.height }.max || 0) + (PADDING_Y * 2)

      super
    end

    public
    def add(element)
      element.x = x + width - PADDING_X + SPACING_X
      element.y = y + PADDING_Y

      super
    end
  end
end
end