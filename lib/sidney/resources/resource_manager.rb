require 'singleton'
require 'set'

module RSiD
  class ResourceManager
    include Singleton
    
    STRING_TABLE_FILE = File.join("..", "test_data", "input", "resourceCache", "stringDatabase.txt")
    RESOURCE_TYPES = [:sprite, :object, :tile, :room, :scene, :phrase, :song, :timbre, :scale]

    def initialize
      @resource_names = Hash.new # name => id
      @resources = Hash.new      # id => object
      
      RESOURCE_TYPES.each do |type|
        @resource_names[type] = Hash.new { |hash, key| hash[key] = Array.new }
        @resources[type] = Hash.new { |hash, key| hash[key] = Array.new }
      end

      File.open(STRING_TABLE_FILE) do |file|
        file.each_line do |line|
          if line =~ /^(.+) (.+) ([\s.*]+)$/
            id, type, name = $1.to_sym, $2.to_sym, $3
            
            @resource_names[type][name] << id
          end
        end
      end
    end

    def register(resource)
      #raise Exception if @resources[type][resource.id]
      
      #@resource_names[resource.name].add = resource.id
      #@resources[resource.id] = resource
    end

    def find(type, search = "")
      terms = search.trim.split(/\s+/)
      patterns = terms.map {|term| Regexp.new(term) }
      ids = []

      @resource_names[type].each_pair do |name, id|
        fail = false

        patterns.each do |pattern|
           unless name =~ pattern
             fail = true
             break
           end
        end

        ids << id unless fail
      end

      ids
    end
  end
end