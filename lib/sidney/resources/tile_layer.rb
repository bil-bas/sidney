require_relative 'tile'

module RSiD
  # Tile layer within a Room.
  class TileLayer < ActiveRecord::Base    
    belongs_to :room
    belongs_to :tile

    public
    def draw_on_image(canvas)
      if object = tile and object != Tile.default
        object.draw_on_image(canvas, x * Tile::WIDTH, y * Tile::HEIGHT)
      end
      canvas
    end
  end
end