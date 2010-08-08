class Selection
  public
  def initialize
    @list = []
  end

  public
  def add(object)
    object.selected = true
    @list.push(object)

    nil
  end

  public
  def remove(object)
    @list.delete(object)
    object.selected = false

    nil
  end

  public
  def clear
    @list.each { |o| o.selected = false }
    @list.clear

    nil
  end

  public
  def include?(object)
    @list.include? object
  end

  public
  def size; @list.size; end
  def empty?; @list.empty?; end
  def [](index); @list[index]; end
  def each(&block); @list.each(&block); end
  def to_a; @list.dup; end
end