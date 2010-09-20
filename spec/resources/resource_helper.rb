require_relative "helper"

require_relative 'room'
require_relative 'scene'
require_relative 'sprite'
require_relative 'sprite_layer'
require_relative 'state_object'
require_relative 'state_object_layer'
require_relative 'tile'
require_relative 'tile_layer'

include RSiD

RESOURCE_CLASSES = [Room, Scene, Sprite, SpriteLayer, StateObject, StateObjectLayer, Tile, TileLayer]

share_examples_for "Resource" do
  before :each do

    RESOURCE_CLASSES.each { |r| r.delete_all }
    Resource.clear_defaults
    
    @resource_file_read = File.join(CACHE_IN, described_class.type, @uid)
    @resource_file_saved = File.join(CACHE_OUT, described_class.type, @uid)

    File.open(File.join(CACHE_IN, described_class.type, @uid), "rb") do |file|
      @data = file.read
    end

    # Ensure that the sprites will load/save to the correct location.
    Resource::CACHE_DIR.sub!(/.*/, CACHE_IN)

    # Create an example resource.
    @resource = described_class.load(@uid)
  end

  describe "initialize()" do
    it "should store the name" do
      @resource.name.should == @name
    end

    it "should store the uid" do
      @resource.uid.should == @uid
    end

    it "should calculate the uid if not provided" do
      @resource = described_class.generate(data: @data)
      @resource.uid.should == @uid
    end
  end

  describe "default()" do
    before :each do
      @default_resource = described_class.default
    end

    it "should always create the same object" do
      @default_resource.should equal described_class.default
    end

    it "should default name to 'default'" do
      @default_resource.name.should == 'default'
    end
  end
  
  describe "to_binary()" do
    it "should serialise to binary what it was originally given" do
      @resource.to_binary.should == @data
    end
  end

  describe "save_file()" do
    it "should save an identical data file as it loaded" do
      File.delete(@resource_file_saved) if File.exists?(@resource_file_saved)
      described_class::CACHE_DIR.sub!(/.*/, CACHE_OUT)
      @resource.save_file
      File.read(@resource_file_saved).should == File.read(@resource_file_read)
    end
  end

  describe "restore from database" do
    it "should return an identical record as it saved" do
      res = described_class.where(uid: @uid).first
      res.recalculate_uid
      res.uid.should == @uid
    end
  end
end
