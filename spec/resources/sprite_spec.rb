require_relative 'visual_resource_helper'

require 'sprite'
include RSiD

describe Sprite do
  before :each do
    @uid = '009a8897cf6b'
    @name = 'grapefruit'
  end

  it_should_behave_like "VisualResource"

#  OUTLINE_CREATED = File.join(GENERATED_DIR, 'sprite_outlines', "outline.png")

  describe "default()" do
    before :each do
      @default_resource = described_class.default
    end

    it "should be black and transparent" do
      color = [0, 0, 0, 1]
      (0...16).each do |y|
        (0...16).each do |x|
          @default_resource.to_image.pixel(x, y).should == color
        end
      end
    end
  end

  describe "to_tile()" do
    before :each do
      @tile = @resource.to_tile
    end

    it "should be a Tile" do
      @tile.should be_a_kind_of Tile
    end

    it "should have a different uid, but the same name and colors" do
      @tile.uid.should_not == @resource.uid
      @tile.uid.should_not be_nil
      
      @tile.name.should == @resource.name
      @tile.colors.should == @resource.colors
    end

    it "should be opaque" do
      (0...16).each do |y|
        (0...16).each do |x|
          @tile.to_image.pixel(x, y).should == @resource.to_image.pixel(x, y)
        end
      end
    end
  end
end