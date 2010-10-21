require_relative 'container'

module Sidney
module Gui
  # A vertically aligned element packing container.
  class VerticalPacker < Container
    protected
    def recalc
      rect.width = (@children.map {|c| c.width }.max || 0) + (PADDING_X * 2)

      rect.height = @children.inject(0) {|total, c| total + c.height } +
                 (PADDING_Y * 2) + (SPACING_Y * [@children.size - 1, 0].max)
      super
    end

    public
    def add(element)
      element.x = x + PADDING_X
      element.y = y + height - PADDING_Y + SPACING_Y

      super
    end
  end
end
end