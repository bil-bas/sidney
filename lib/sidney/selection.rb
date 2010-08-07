class Selection
  public
  def initialize
    @list = []
  end

  public
  def push(object)
    object.selected = true
    @list.push(object)
  end

  public
  def clear
    @list.each { |o| o.selected = false }
    @list.clear
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
  def items; @list.dup; end
end