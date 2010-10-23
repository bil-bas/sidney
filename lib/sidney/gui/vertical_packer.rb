# encoding: utf-8

require_relative 'packer'

module Sidney
module Gui
  # A vertically aligned element packing container.
  class VerticalPacker < Packer
    public
    def recalc
      old_width, old_height = width, height

      total_height = padding_y

      @children.each.with_index do |child, index|
        child.x = x + padding_x
        child.y = y + total_height
        total_height += child.height
        total_height += spacing_y unless index == @children.size - 1
      end

      rect.height = total_height + padding_y
      rect.width = (@children.map {|c| c.width }.max || 0) + (padding_x * 2)

      super

      parent.recalc if parent and (width != old_width or height != old_height)

      nil
    end
  end
end
end