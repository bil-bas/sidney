class Dragger
  MIN_DRAG_DISTANCE = 2
  
  attr_reader :x, :y, :items

  def active?; @active; end

  protected
  def initialize
    @items = []
  end

  public
  def begin(items, x, y)
    @items = items.to_a.dup
    @initial_x, @initial_y = x, y
    @last_x, @last_y = x, y
    @active = false

    nil
  end

  public
  def end
    @items.each { |o| o.dragging = false }
    @items.clear

    nil
  end

  # Move all dragged object back to original positions.
  public
  def reset
    if @active
      @items.each do |o|
        o.x += @initial_x - @last_x
        o.y += @initial_y - @last_y 
      end

      @active = false
    end

    self.end

    nil
  end

  public
  def update(x, y)
    if @active
      @items.each do |o|
        o.x += x - @last_x
        o.y += y - @last_y
      end

      @last_x, @last_y = x, y
    else
      if distance(@initial_x, @initial_y, x, y) > MIN_DRAG_DISTANCE
        @items.each { |o| o.dragging = true }
        @active = true
      end
    end

    nil
  end

  public
  def empty?
    @items.empty?
  end
end