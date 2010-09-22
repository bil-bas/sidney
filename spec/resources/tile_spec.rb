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
    subject { described_class.default }

    it "should be blank and opaque" do
      blank = [0, 0, 0, 1]
      (0...16).each do |y|
        (0...16).each do |x|
          subject.to_image.get_pixel(x, y).should == blank
        end
      end
    end
  end

  describe "to_sprite()" do
    subject { described_class.load(@uid) }

    before :each do
      @sprite = subject.to_sprite
    end

    it "should be a Sprite" do
      @sprite.should be_a_kind_of Sprite
    end

    it "should have the same uid, name and image data" do
      @sprite.uid.should == subject.uid
      @sprite.name.should == subject.name
      @sprite.image.should == subject.image
    end
  end
end