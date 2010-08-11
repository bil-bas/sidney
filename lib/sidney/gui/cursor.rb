module Sidney
class Cursor < GameObject
  def initialize(options = {})
    super({:image => "mouse.png", :center => 0, :zorder => ZOrder::CURSOR}.merge(options))

    nil
  end

  def update
    self.x, self.y = $window.mouse_x, $window.mouse_y

    super

    nil
  end
end
end