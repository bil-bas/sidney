# encoding: utf-8

require_relative 'element'

module Sidney
module Gui
  # A container that contains Elements.
  class Container < Element
    DEBUG_BORDER_COLOR = Color.rgb(0, 0, 255) # Color to draw an outline in when debugging layout.

    # Recalculate the size of the container.
    # Should be overridden by any descendant that manages the positions of its children.
    protected
    def layout
      # This assumes that the container overlaps all the children.

      # Move all children if we have moved.
      @children.each.with_index do |child, index|
        child.x = x + padding_x
        child.y = y + padding_y
      end

      # Make us as wrap around the largest child.
      rect.width = (@children.map {|c| c.width }.max || 0) + padding_x * 2
      rect.height = (@children.map {|c| c.height }.max || 0) + padding_y * 2

      super
    end

    public
    def each(&block)
      @children.each &block
    end

    public
    def x=(value)
      each {|c| c.x += value - x }
      super(value)
    end

    public
    def y=(value)
      each {|c| c.y += value - y }
      super(value)
    end

    protected
    def initialize(parent, options = {})
      @children = []

      super(parent, options)
    end

    public
    def add(element)
      element.send :parent=, self
      @children.push element

      recalc
      nil
    end

    public
    def remove(element)
      @children.delete element
      element.send :parent=, nil

      recalc
      nil
    end

    public
    def clear
      @children.each {|child| child.parent = nil }
      @children.clear

      recalc

      nil
    end

    public
    def draw
      if debug_mode?
        $window.draw_box x, y, width, height, z, DEBUG_BORDER_COLOR
        font.draw self.class.name, x, y, z + 0.001
      end

      each { |c| c.draw }
    end

    public
    def update
      each { |c| c.update }
    end

    # Returns the element within this container that was hit,
    # @return [Element, nil] The element hit, otherwise nil.
    public
    def hit_element(x, y)
      @children.reverse_each do |child|
        if child.is_a? Container
          if element = child.hit_element(x, y)
            return element
          end
        else
          return child if child.hit?(x, y)
        end
      end

      nil
    end
  end
end
end