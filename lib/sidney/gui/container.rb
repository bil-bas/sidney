# encoding: utf-8

require_relative 'element'

module Sidney
module Gui
  # A container that contains GuiElements.
  # @abstract
  class Container < Element
    DEFAULT_SPACING_X, DEFAULT_SPACING_Y = 5, 5

    attr_reader :spacing_x, :spacing_y

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
      options = {
        spacing_x: DEFAULT_SPACING_X,
        spacing_y: DEFAULT_SPACING_Y,
      }.merge! options

      @spacing_x = options[:spacing_x]
      @spacing_y = options[:spacing_y]
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