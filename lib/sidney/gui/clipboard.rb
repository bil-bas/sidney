module Sidney
class Clipboard
  attr_reader :x, :y, :items

  protected
  def initialize
    @items = []
  end

  public
  def copy(items)
    @items = items.to_a.dup
  end

  public
  def empty?
    @items.empty?
  end
end
end