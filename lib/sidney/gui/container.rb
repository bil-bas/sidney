# encoding: utf-8

require_relative 'element'

module Sidney
module Gui
  # A container that contains Elements.
  class Container < Element
    DEBUG_BORDER_COLOR = Color.rgb(0, 0, 255) # Color to draw an outline in when debugging layout.

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
      options[:border_color] = DEBUG_BORDER_COLOR if options[:debug] or debug_mode?

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

    protected
    def draw_foreground
      each { |c| c.draw }

      font.draw self.class.name, x, y, z if debug_mode?

      nil
    end

    public
    def update
      each { |c| c.update }

      nil
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