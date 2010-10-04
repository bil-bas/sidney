require_relative 'visual_resource'
require_relative 'tile'
require_relative 'tile_layer'

module RSiD
  class Room < VisualResource  
    has_many :tile_layers
    has_many :tiles, :through => :tile_layers

    has_many :scenes

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

    # @param [Hash] options
    # @option options [String] :name Name of the room
    # @option options [Array<String>] :tile_ids List of uids
    # @option options [Array<Boolean>] :walls List of blocking walls
    def initialize(options)
      if options[:tile_ids] and options[:walls]
        @tile_ids_tmp = options[:tile_ids]
        @walls_tmp = options[:walls]

        options.delete(:tile_ids)
        options.delete(:walls)
      else
        raise ArgumentError.new
      end

      super(options)
    end
  
    def create_or_update
      success = super

      # If we save the room, then create the appropriate tile layers.
      if success and @tile_ids_tmp and @walls_tmp
        create_tile_layers(@tile_ids_tmp, @walls_tmp)
        @tile_ids_tmp = @walls_tmp = nil
      end

      success
    end

    def self.attributes_from_data(data, attributes = {})
      version, offset = read_version(data)
      
      imported_tile_ids = data[offset, UID_NUM_BYTES * IMPORT_AREA].unpack(UID_PACK * IMPORT_AREA)
      offset = UID_NUM_BYTES * IMPORT_AREA

      # TODO: If there is enough data, read in walls, otherwise assume they are passable.
      imported_walls = data[offset, IMPORT_AREA].unpack("C*")
      imported_walls.map! { |wall| wall == BLOCKED }
      offset += IMPORT_AREA

      # Convert the 13x13 SiD grid to 20x15 Sidney grid.
      tile_ids = Array.new(GRID_AREA, Tile.default.id)
      walls = Array.new(GRID_AREA, IMPORT_WALLS)

      (0...IMPORT_HEIGHT).each do |y|
        (0...IMPORT_WIDTH).each do |x|
          index = (x + IMPORT_X_OFFSET) + ((y + IMPORT_Y_OFFSET) * GRID_WIDTH)
          tile_ids[index] = imported_tile_ids[x + y * IMPORT_WIDTH]
          walls[index] = imported_walls[x + y * IMPORT_WIDTH]
        end
      end

      attributes[:tile_ids] = tile_ids
      attributes[:walls] = walls

      super(data[offset..-1], attributes)
    end

    def self.default_attributes(attributes = {})
      attributes[:tile_ids] = Array.new(GRID_AREA, Tile.default.id) unless attributes[:tile_ids]
      attributes[:walls] = Array.new(GRID_AREA, DEFAULT_WALLS) unless attributes[:walls]
      
      super(attributes)
    end

    # Create all the tiles layers required by this room.
    #
    # @param [Array<String>] tile_ids
    # @param [Array<Boolean>] walls
    #
    # @return [nil]
    def create_tile_layers(tile_ids, walls)
      (0...GRID_HEIGHT).each do |y|
        (0...GRID_WIDTH).each do |x|
          tile_id = tile_ids[x + y * GRID_WIDTH]
          wall = walls[x + y * GRID_WIDTH]
          TileLayer.create!(room_id: id, tile_id: tile_id, x: x, y: y, blocked: wall)
        end
      end

      nil
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
      if @tile_ids_tmp and @walls_tmp
        tile_ids = @tile_ids_tmp
        walls = @walls_tmp.map {|wall| wall ? BLOCKED : PASSABLE }
      else     
        tile_ids = []
        walls = []

        layers_by_x_y.each do |layer|
          tile_ids.push layer.tile_id
          walls.push(layer.blocked ? BLOCKED : PASSABLE)
        end
      end

      tile_ids.pack(UID_PACK * GRID_AREA) +
        walls.pack("C#{GRID_AREA}") +
        super
    end

    def create_image
      tile_layers.each do |layer|
        layer.draw
      end

      $window.to_devil(0, 0, WIDTH, HEIGHT, clear: true)
    end
  end
end