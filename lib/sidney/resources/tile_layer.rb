# encoding: utf-8

require_relative 'tile'

module Sidney
  # Tile layer within a Room.
  class TileLayer < ActiveRecord::Base    
    belongs_to :room
    belongs_to :tile

    public
    def draw
      if object = tile and object != Tile.default
        object.draw x * Tile::WIDTH, y * Tile::HEIGHT
      end
    end
  end
end