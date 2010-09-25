require_relative 'visual_resource'
require_relative 'tile'
require_relative 'tile_layer'

module RSiD
  class Room < VisualResource  
    has_many :tile_layers
    has_many :tiles, :through => :tile_layers

    has_many :scenes

    set_primary_key :uid

    IMPORT_WIDTH, IMPORT_HEIGHT = 13, 13 # = 208x208
    IMPORT_X_OFFSET, IMPORT_Y_OFFSET = 3, 1 # Move SiD objects 3 right and 1 down.
    IMPORT_AREA = IMPORT_WIDTH * IMPORT_HEIGHT
    IMPORT_WALLS = true # Walls for area outside of import.


    GRID_WIDTH, GRID_HEIGHT = 20, 15 # = 320x240
    GRID_AREA = GRID_WIDTH * GRID_HEIGHT
    WIDTH = GRID_WIDTH * Tile::WIDTH
    HEIGHT = GRID_HEIGHT * Tile::WIDTH

    PASSABLE = 0
    BLOCKED = 1
    DEFAULT_WALLS = false

    # :name - Name of the room [String]
    # :tile_uids - Array of uids [Array(169) of String]
    # :walls - Array of blocking walls [Array(169) of Boolean]
    def initialize(options)
      if options[:tile_uids] and options[:walls]
        @tile_uids_tmp = options[:tile_uids]
        @walls_tmp = options[:walls]

        options.delete(:tile_uids)
        options.delete(:walls)
      else
        raise ArgumentError.new
      end

      super(options)
    end
  
    def create_or_update
      success = super

      # If we save the room, then create the appropriate tile layers.
      if success and @tile_uids_tmp and @walls_tmp
        create_tile_layers(@tile_uids_tmp, @walls_tmp)
        @tile_uids_tmp = @walls_tmp = nil
      end

      success
    end

    def self.attributes_from_data(data, attributes = {})
      version, offset = read_version(data)
      
      imported_tile_uids = data[offset, UID_NUM_BYTES * IMPORT_AREA].unpack(UID_PACK * IMPORT_AREA)
      offset = UID_NUM_BYTES * IMPORT_AREA

      # TODO: If there is enough data, read in walls, otherwise assume they are passable.
      imported_walls = data[offset, IMPORT_AREA].unpack("C*")
      imported_walls.map! { |wall| wall == BLOCKED }
      offset += IMPORT_AREA

      # Convert the 13x13 SiD grid to 20x15 Sidney grid.
      tile_uids = Array.new(GRID_AREA, Tile.default.uid)
      walls = Array.new(GRID_AREA, IMPORT_WALLS)

      (0...IMPORT_HEIGHT).each do |y|
        (0...IMPORT_WIDTH).each do |x|
          index = (x + IMPORT_X_OFFSET) + ((y + IMPORT_Y_OFFSET) * GRID_WIDTH)
          tile_uids[index] = imported_tile_uids[x + y * IMPORT_WIDTH]
          walls[index] = imported_walls[x + y * IMPORT_WIDTH]
        end
      end

      attributes[:tile_uids] = tile_uids
      attributes[:walls] = walls

      super(data[offset..-1], attributes)
    end

    def self.default_attributes(attributes = {})
      attributes[:tile_uids] = Array.new(GRID_AREA, Tile.default.uid) unless attributes[:tile_uids]
      attributes[:walls] = Array.new(GRID_AREA, DEFAULT_WALLS) unless attributes[:walls]
      
      super(attributes)
    end

    # Create all the tiles layers required by this room.
    # tile_uids:: [Array of UID] 
    # walls:: [Array of Boolean]
    def create_tile_layers(tile_uids, walls)
      (0...GRID_HEIGHT).each do |y|
        (0...GRID_WIDTH).each do |x|
          tile_uid = tile_uids[x + y * GRID_WIDTH]
          wall = walls[x + y * GRID_WIDTH]
          TileLayer.create!(room_id: uid, tile_id: tile_uid, x: x, y: y, blocked: wall)
        end
      end
    end

    def blocked?(x, y)
      layer(x, y).blocked
    end

    def layer(x, y)
      tile_layers.where(x: x, y: y).first
    end

    def layers_by_x_y
      tile_layers.order(:x, :y)
    end

    def tile(x, y)
      layer = layer(x, y)
      layer ? layer.tile : nil
    end

    def to_binary
      # If we haven't been saved to the database yet, then we are
      # just using the temporary values stored in the instance,
      # otherwise read the values in from the database.
      if @tile_uids_tmp and @walls_tmp
        tile_uids = @tile_uids_tmp
        walls = @walls_tmp.map {|wall| wall ? BLOCKED : PASSABLE }
      else     
        tile_uids = []
        walls = []

        layers_by_x_y.each do |layer|
          tile_uids.push layer.tile_uid
          walls.push(layer.blocked ? BLOCKED : PASSABLE)
        end
      end

      tile_uids.pack(UID_PACK * GRID_AREA) +
        walls.pack("C#{GRID_AREA}") +
        super
    end

    def create_image
      img = Image.create(WIDTH, HEIGHT)

      tile_layers.each do |layer|
        layer.draw_on_image(img)
      end

      img
    end
  end
end