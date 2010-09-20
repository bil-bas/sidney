require_relative 'visual_resource_helper'

require_relative 'sprite'
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
      color = Pixel.new(0, 0, 0, 255)
      (0...16).each do |y|
        (0...16).each do |x|
          @default_resource.pixel(x, y).should == color
          @default_resource.transparent?(x, y).should be_true
        end
      end
    end
  end

#  describe "outline()" do
#    it "should generate an outline of the sprite shape" do
#      File.delete(OUTLINE_CREATED) if File.exists?(OUTLINE_CREATED)
#      @resource.outline.write(OUTLINE_CREATED)
#      File.exist?(OUTLINE_CREATED).should be_true
#    end
#  end

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
          @tile.pixel(x, y).should == @resource.pixel(x, y)
          @tile.transparent?(x, y).should be_false
        end
      end
    end
  end

#  describe "outline() ALL" do
#    it "should generate an outline of the sprite shape" do
#      Dir[File.join(CACHE_IN, described_class.type, "*")].each do |filename|
#        object = described_class.load(File.basename(filename))
#        object.outline.save(File.join(GENERATED_DIR, "#{described_class.type}_outlines", "#{object.name} - #{File.basename(filename)}.png"))
#      end
#    end
#  end
end