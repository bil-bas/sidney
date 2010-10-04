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

share_examples_for "Resource" do
  before :each do
    @resource_file_read = File.join(CACHE_IN, described_class.type, @id.upcase)

    File.open(@resource_file_read, "rb") do |file|
      @data = file.read
    end

    # Create an example resource.
    @resource = described_class.load(@id)
    @imported_id = @resource.id # UID changes in Sid import into Sidney
  end

  describe "#initialize" do
    it "should store the name" do
      @resource.name.should == @name
    end

    it "should store a id" do
      @resource.id.should_not be_nil
    end

    it "should calculate the id if not provided" do
      @resource = described_class.generate(data: @data, id: @id)
      @resource.id.should == @imported_id
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
      res = described_class.where(id: @imported_id).first
      res.recalculate_id
      res.id.should == @imported_id
    end
  end
end
