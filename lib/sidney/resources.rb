require_relative 'resources/sprite'
require_relative 'resources/tile'
require_relative 'resources/room'
require_relative 'resources/state_object'
require_relative 'resources/scene'
include RSiD

DATA_DIR = File.join(ROOT_PATH, "test_data")

INPUT_DIR =  File.join(DATA_DIR, "input")
GENERATED_DIR = File.join(DATA_DIR, "generated")

CACHE_IN = File.join(INPUT_DIR, 'resourceCache')
CACHE_OUT = File.join(GENERATED_DIR, 'resourceCache')

Resource::CACHE_DIR.sub!(/.*/, CACHE_IN)

=begin
[Sprite, Tile, Room, StateObject, Scene].each do |resource_class|
  unless resource_class.type == "object"
    Dir[File.join(CACHE_IN, resource_class.type, "*")].each do |filename|
      object = resource_class.load(File.basename(filename))
      object.id
      object.to_image
      object.outline if resource_class.type == "sprite"
      object.to_image.to_devil {|devil| devil.save(File.join(GENERATED_DIR, "#{resource_class.type}_images", "#{object.name} - #{File.basename(filename)}.png")) }
    end
  end
end
=end