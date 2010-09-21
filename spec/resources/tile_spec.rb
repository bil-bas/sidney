require_relative 'visual_resource_helper'

require 'tile'
include RSiD

describe Tile do
  before :all do
    $window = Gosu::Window.new(640, 480, false)
  end

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
      pending "to_image getting fixed"
      blank = [0, 0, 0, 1]
      (0...16).each do |y|
        (0...16).each do |x|
          @default_resource.to_image.pixel(x, y).should == blank
        end
      end
    end

    it "should be opaque" do
      pending "to_image getting fixed"
      (0...16).each do |y|
        (0...16).each do |x|
          @default_resource.to_image.pixel(x, y)[3].should == 0
        end
      end
    end
  end

=begin
describe "to_sprite()" do
    before :each do
      @default_resource = described_class.default
      @sprite = @default_resource.to_sprite
    end

    it "should be a Sprite" do
      @sprite.should be_a_kind_of Sprite
    end

    it "should have a different uid, but same name and colors" do

      @sprite.uid.should_not be_nil
      @sprite.uid.should_not == @default_resource.uid

      @sprite.name.should == @default_resource.name
      @sprite.image.should == @default_resource.image
    end

    it "should be opaque" do
      pending "to_image getting fixed"
      (0...16).each do |y|
        (0...16).each do |x|
          @sprite.to_image.pixel(x, y)[3].should == 0
        end
      end
    end
  end
=end
end