class Clipboard
  attr_reader :x, :y, :items

  protected
  def initialize
    @items = []
  end

  public
  def copy(items)
    @items = items.dup
  end

  public
  def empty?
    @items.empty?
  end
end