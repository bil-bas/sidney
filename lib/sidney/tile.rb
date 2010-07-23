class Tile < GameObject
  trait :retrofy

  def initialize(options = {})
    super({:center => 0, :zorder => ZOrder::BACKGROUND}.merge(options))
  end

  def setup
    img = Image["mouse.png"]
    image.splice(img, rand(5), rand(5), :crop => [8, 8, 10, 10] )
    #self.image = Image.new($window, image, true)
    #image.rect(5, 0, 10, 5, :fill => true, :texture => img)
    nil
  end

  def draw(x, y)
    image.draw((self.x * factor_x) + x, (self.y * factor_y) + y, zorder, factor_x, factor_y)
  end
end