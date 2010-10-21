require_relative 'element'

module Sidney
module Gui
  # A container that contains GuiElements.
  # @abstract
  class Container < Element
    SPACING_X, SPACING_Y = 5, 5
    PADDING_X, PADDING_Y = 5, 5

    # Recalculate the size of the container.
    public
    def recalc
      nil
    end

    public
    def each(&block)
      @children.each &block
    end

    public
    def x=(value)
      rect.x = value
      difference = value - rect.x
      each {|c| c.x += difference }
    end

    public
    def y=(value)
      rect.y = value
      difference = value - rect.y
      each {|c| c.y += difference }
    end

    protected
    def initialize(parent, options = {})
      @children = []

      super(parent, options)

      recalc
    end

    public
    def add(element)
      element.parent = self
      @children.push element

      recalc
      nil
    end

    public
    def draw
      each { |c| c.draw }
    end

    public
    def update
      each { |c| c.update }
    end

    # Returns the element within this container that was hit,
    # @return [GuiElement, nil] The element hit, otherwise nil.
    public
    def hit_element(x, y)
      @children.each do |child|
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