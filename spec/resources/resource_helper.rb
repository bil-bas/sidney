require_relative '../helper'

require 'room'
require 'scene'
require 'sprite'
require 'sprite_layer'
require 'state_object'
require 'state_object_layer'
require 'tile'
require 'tile_layer'

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
    @imported_uid = @resource.uid # UID changes in Sid import into Sidney
  end

  describe "#initialize" do
    it "should store the name" do
      @resource.name.should == @name
    end

    it "should store a uid" do
      @resource.uid.should_not be_nil
    end

    it "should calculate the uid if not provided" do
      @resource = described_class.generate(data: @data, uid: @uid)
      @resource.uid.should == @imported_uid
    end
  end

  describe "#default" do
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

  describe "restore from database" do
    it "should return an identical record as it saved" do
      res = described_class.where(uid: @imported_uid).first
      res.recalculate_uid
      res.uid.should == @imported_uid
    end
  end
end
