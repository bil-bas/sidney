require_relative 'visual_resource_helper'

require_relative 'tile'
include RSiD

describe Tile do
  before :each do
    @uid = '0d183059ae8b'
    @name = 'court'
  end

  it_should_behave_like "VisualResource"

  describe "default()" do
    before :each do
      @default_resource = described_class.default
    end

    it "should be blank" do
      blank = Pixel.new(0, 0, 0, 255)
      (0...16).each do |y|
        (0...16).each do |x|
          @default_resource.pixel(x, y).should == blank
        end
      end
    end

    it "should be opaque" do
      (0...16).each do |y|
        (0...16).each do |x|
          @default_resource.transparent?(x, y).should be_false
        end
      end
    end
  end

  describe "to_sprite()" do
    before :each do
      @sprite = @resource.to_sprite
    end

    it "should be a Sprite" do
      @sprite.should be_a_kind_of Sprite
    end

    it "should have a different uid, but same name and colors" do
      @sprite.uid.should_not be_nil
      @sprite.uid.should_not == @resource.uid

      @sprite.name.should == @resource.name
      @sprite.colors.should == @resource.colors
    end

    it "should be opaque" do
      (0...16).each do |y|
        (0...16).each do |x|
          @sprite.transparent?(x, y).should be_false
        end
      end
    end
  end
end