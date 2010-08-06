class History
  class Command
    protected
    def initialize

    end

    public
    def do

    end

    public
    def undo

    end
  end

  public
  def initialize
    @commands = []
    @index = -1 # Last command that was performed.
  end

  public
  def add(command)
    @commands = @commands[0...@index]
    @index = @commands.size
    @commands << command    
    command.do
  end

  public
  def undo
    raise "Can't undo unless there are commands in past" unless can_undo?
    @commands[@index].undo
    @index -= 1
  end

  public
  def redo
    raise "Can't redo if there are no commands in the future" unless can_redo?
    @index += 1
    @commands[@index].do
  end

  public
  def can_undo?
    @index >= 0
  end

  public
  def can_redo?
    @index == (@commands.size - 1)
  end
end