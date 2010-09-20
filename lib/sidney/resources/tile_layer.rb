require_relative 'tile'

module RSiD
  # Tile layer within a Room.
  class TileLayer < ActiveRecord::Base    
    belongs_to :room
    belongs_to :tile

    def tile
      Tile.where(uid: tile_uid).first
    end

    def room
      Room.where(uid: room_uid).first
    end
  end
end