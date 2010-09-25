require_relative 'tile'
require_relative 'sprite'
require_relative 'room'
require_relative 'state_object'
require_relative 'scene'

module RSiD
  RESOURCE_TYPES = [Tile, Room, Sprite, StateObject, Scene]

  def self.import_resources(path)
    RESOURCE_TYPES.each do |klass|
      files =  Dir.glob(File.join(path, klass.type, '*'))
      puts "Importing #{files.size} #{klass} resources (#=10)"

      start = Time.now.to_f

      files.each_with_index do |sid_data_file, i|
        klass.import(File.basename(sid_data_file).downcase, sid_data_file)
        print "#" if i % 10 == 9
      end

      duration = Time.now.to_f - start

      puts
      puts "Took #{"%.2f" % duration}s (#{"%.2f" % [duration / files.size]}s per resource)"
      puts
    end
  end
end