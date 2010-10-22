# encoding: utf-8

require_relative 'container'

module Sidney
module Gui
  # A vertically aligned element packing container.
  class HorizontalPacker < Container
    protected
    def initialize(parent, options = {}, &block)
      super(parent, options)
      post_init &block
    end

    public
    def recalc
      old_width, old_height = width, height

      total_width = padding_x

      @children.each.with_index do |child, index|
        child.x = x + total_width
        child.y = y + padding_y
        total_width += child.width
        total_width += spacing_x unless index == @children.size - 1
      end

      rect.width = total_width + padding_x
      rect.height = (@children.map {|c| c.height }.max || 0) + (padding_y * 2)

      super

      parent.recalc if parent and (width != old_width or height != old_height)

      nil
    end
  end
end
end