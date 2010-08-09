require 'chingu/game_object'

class Tile < GameObject
  def initialize(options = {})
    super({:center => 0, :zorder => ZOrder::BACKGROUND}.merge!(options))
  end
end