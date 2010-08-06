class Clipboard
  attr_reader :x, :y, :items

  protected
  def initialize
    @items = []
    @x, @y = nil, nil
  end

  public
  def copy(items, x, y)
    @items = items.dup
    @x, @y = x, y
  end

  public
  def empty?
    @items.empty?
  end
end