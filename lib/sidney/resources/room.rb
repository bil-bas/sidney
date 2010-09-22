require_relative 'visual_resource'
require_relative 'tile'
require_relative 'tile_layer'

module RSiD
  class Room < VisualResource  
    has_many :tile_layers
    has_many :tiles, :through => :tile_layers

    has_many :scenes

    set_primary_key :uid
    attr_accessible :walls
    serialize :walls
    
    GRID_WIDTH = GRID_HEIGHT = 13
    GRID_AREA = GRID_WIDTH * GRID_HEIGHT
    WIDTH = GRID_WIDTH * Tile::WIDTH
    HEIGHT = GRID_HEIGHT * Tile::WIDTH

    PASSABLE = 0
    BLOCKED = 1

    # :name - Name of the room [String]
    # :tile_uids - Array of uids [Array(169) of String]
    # :walls - Array of blocking walls [Array(169) of Boolean]
    def initialize(options)
      if options[:tile_uids] and options[:walls]
        @tile_uids_tmp = options[:tile_uids]
        options.delete(:tile_uids)
        @walls_tmp = options[:walls]
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
      
      attributes[:tile_uids] = data[offset, UID_NUM_BYTES * GRID_AREA].unpack(UID_PACK * GRID_AREA)
      offset = UID_NUM_BYTES * GRID_AREA

      # TODO: If there is enough data, read in walls, otherwise assume they are passable.
      attributes[:walls] = data[offset, GRID_AREA].unpack("C*")
      attributes[:walls].map! { |wall| wall == BLOCKED }
      offset += GRID_AREA

      super(data[offset..-1], attributes)
    end

    def self.default_attributes(attributes = {})
      attributes[:tile_uids] = Array.new(GRID_AREA, Tile.default.uid) unless attributes[:tile_uids]
      attributes[:walls] = Array.new(GRID_AREA, false) unless attributes[:walls]
      
      super(attributes)
    end

    # Create all the tiles layers required by this room.
    # tile_uids:: [Array of UID] 
    # walls:: [Array of Boolean]
    def create_tile_layers(tile_uids, walls)
      (0...GRID_WIDTH).each do |y|
        (0...GRID_WIDTH).each do |x|
          tile_uid = tile_uids[x + (y * GRID_WIDTH)]
          self.class.benchmark("Loading tile #{tile_uid}") do
            Tile.load(tile_uid)
          end
          wall = walls[x + (y * GRID_WIDTH)]
          self.class.benchmark("Creating TileLayer #{x},#{y} #{uid}->#{tile_uid}") do
            layer = TileLayer.create!(room_uid: uid, tile_uid: tile_uid, x: x, y: y, blocked: wall)
          end
        end
      end
    end

    def blocked?(x, y)
      layer(x, y).blocked
    end

    def layer(x, y)
      TileLayer.where(room_uid: uid, x: x, y: y).first
    end

    def layers_by_x_y
      TileLayer.where(room_uid: uid).order(:x, :y)
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

    def to_image
      image = Image.create(WIDTH, HEIGHT)

      layers_by_x_y.each do |layer|
        tile = Tile.load(layer.tile_uid)
        unless tile == Tile.default
          tile.draw_on_image(image, layer.x * Tile::WIDTH, layer.y * Tile::HEIGHT)
        end
      end
      
      image
    end
  end
end